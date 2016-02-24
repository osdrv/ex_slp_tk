defmodule ExSlp.Server do

  alias ExSlp.Tool

  @slpd    "slpd"

  def sys_status do
    { Tool.status(), server_status() }
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

    case res = Tool.exec_cmd( args, :register, [ format_servise_url( service ), opts ] ) do
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
    Tool.exec_cmd( args, :deregister, [ format_servise_url( service ) ] )
  end


  defp format_servise_url( service ) do
    case Regex.run( ~r/^service\:/, service ) do
      nil -> "service:#{service}"
      _   -> service
    end
  end

end

