defmodule ExSlp.Server do

  alias ExSlp.Tool
  import ExSlp.Util, only: [ format_servise_url: 1, format_args: 1, format_opts: 1 ]

  @slpd "slpd"

  @doc """
  Checks the status of slpd daemon.
  Returns:
      { :ok, pid } # in case of success,
      { :not_running, message } # otherwise.
  """
  def status do
    case :os.cmd( :"ps cax | grep #{@slpd} | awk '{print $1}'" ) do
      []  -> { :not_running, "The server doesn't seem to be running." }
      output ->
        pid = output |> List.to_string |> String.strip |> String.to_integer
        { :ok, pid }
    end
  end

  @doc """
  Registers the service in the local network.
  Takes the `service` specification as a mandatory argument,
  `args` and `opts` as a standard keyword lists (see ExSlp.Client.findsrvs for
  more info on `args`.
  This is the place you should specify the service attributes.
  Check the original documentation for more service internals:
  http://www.openslp.org/doc/html/ProgrammersGuide/SLPReg.html
  Please keep in mind the slpd instance won't track the initiator
  status and moreover it knows nothing about it.
  It's initiator's responsibility to deregister the service
  it registers.
  Returns:
      { :ok, resp } # in case of success,
      { :error, message } # otherwise.
  Example: 
      register( "myservice://192.168.0.10" )
      register( "service:myservice.xyz://192.168.0.10", [ attr1: val1, att2: val2 ] )
      register( "service:myservice.xyz://192.168.0.10", [ l: "en", t: 60 * 60], [] )
  """
  def register( service ), do: register( service, [], [] )
  def register( service, opts ), do: register( service, [], opts )
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

  @doc """
    Deregisters the service which has been registered earlier.
    You should call this method every time the application
    is about to be terminated. The service won't be automatically
    deregistered.
    Takes `service` as a mandatory argument, the same you used
    to register the service.
    `args` is a standard openslp keyword list.
    Returns:
        { :ok, resp } # in case of success
        { :error, reason } # otherwise
  """
  def deregister( service ), do: deregister( service, [] )
  def deregister( service, args ) do
    args = format_args( args )
    case res = Tool.exec_cmd( args, :deregister, [ format_servise_url( service ) ] ) do
      { :ok, "" } -> res
      { :ok, silent_err } ->
        { :error, silent_err }
      _ -> res
    end
  end

end

