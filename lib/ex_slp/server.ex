defmodule ExSlp.Server do

  alias ExSlp.Tool
  import ExSlp.Util, only: [ format_servise_url: 1, format_args: 1, format_opts: 1 ]

  @slpd "slpd"

  def status do
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
    args = format_args( args )
    opts = format_opts( opts )

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
    args = format_args( args )
    Tool.exec_cmd( args, :deregister, [ format_servise_url( service ) ] )
  end

end

