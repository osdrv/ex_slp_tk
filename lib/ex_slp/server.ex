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

  def register( service, args, opts ) do
    args  = Enum.map( args, fn({ k, v }) -> [ "-#{k}", "#{v}" ] end ) |> List.flatten
    opts = Enum.map( opts, fn({ k, v }) -> "(#{k}=#{v})" end )
         |> Enum.join(",")

    if String.length( opts ) > 0 do
      opts = "\"#{opts}\""
    end

    case res = slptool_cmd( args, :register, [ format_servise_url( service ), opts ] ) do
      { :ok, "" } -> res
      { :ok, silent_err } ->
        { :error, silent_err }
      _ -> res
    end
  end


  def deregister( service ) do
    case res = deregister( service, [] ) do
      { :ok, "" } -> res
      { :ok, silent_err } ->
        { :error, silent_err }
      _ -> res
    end

  end

  def deregister( service, args ) do
    args  = Enum.map( args, fn({ k, v }) -> [ "-#{k}", "#{v}" ] end ) |> List.flatten
    slptool_cmd( args, :deregister, [ format_servise_url( service ) ] )
  end


  defp format_servise_url( service ) do
    case Regex.run( ~r/^service\:/, service ) do
      nil -> "service:#{service}"
      _   -> service
    end
  end


  defp slptool_cmd( args, cmd, opts ) do
    case System.cmd( @slptool, args ++ [ cmd | opts ] ) do
      { res, 0 } ->
        { :ok, res |> String.strip }
      { err, 1 } -> { :error, err |> String.strip }
    end
  end

end

