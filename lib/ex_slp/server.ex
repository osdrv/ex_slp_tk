defmodule ExSlp.Server do

  @slptool "slptool"
  @slpd    "slpd"

  def sys_status do
    { toolkit_status(), server_status() }
  end

  def toolkit_status do
    case System.find_executable(@slptool) do
      nil -> { :cmd_unknown, "The command #{@slptool} could not be found. Check your $PATH ENV variable." }
      { error, error_code } -> { :error, error, error_code }
      path ->
        path = String.strip( path )
        case System.cmd( "test", [ "-x", path ] ) do
          { "", 0 } -> { :ok, "System is running." }
          { "", 1 } -> { :not_executable, "The file #{path} is not executable for the current user." }
          { error, error_code } -> { :error, error, error_code }
        end
    end
  end

  def server_status do
    case :os.cmd( :"ps cax | grep #{@slpd} | awk '{print $1}'" ) do
      []  -> { :not_running, "The server doesn't seem to be running." }
      output ->
        pid = output |> List.to_string |> String.strip |> String.to_integer
        { :ok, pid }
    end
  end


  def register( service ) do
    register( service, [], [] )
  end

  def register( service, opts ) do
    register( service, [], opts )
  end

  def register( service, opts, attrs ) do
    opts  = Enum.map( opts, fn({ k, v }) -> "-#{k} #{v}" end )
    attrs = Enum.map( attrs, fn({ k, v }) -> "(#{k}=#{v})" end )
         |> Enum.join(",")

    if String.length( attrs ) > 0 do
      attrs = "\"#{attrs}\""
    end

    service = case Regex.run( ~r/^service\:/, service ) do
      nil -> "service:#{service}"
      _   -> service
    end

    case res = slptool_cmd( :register, [ opts, service, attrs ] |> List.flatten ) do
      { :ok, "" } -> res
      { :ok, silent_err } ->
        { :error, silent_err }
    end
  end


  def deregister( service ) do
    case res = deregister( service, [] ) do
      { :ok, "" } -> res
      { :ok, silent_err } ->
        { :error, silent_err }
    end

  end

  def deregister( service, opts ) do
    opts  = Enum.map( opts, fn({ k, v }) -> "-#{k} #{v}" end )
    slptool_cmd( :deregister, [ opts, service ] |> List.flatten )
  end


  defp slptool_cmd( cmd, opts ) do
    case System.cmd( @slptool, [ cmd | opts ] ) do
      { res, 0 } ->
        { :ok, res |> String.strip }
      { err, 1 } -> { :error, err |> String.strip }
    end
  end

end

