defmodule ExSlp.Service do
  alias ExSlp.Server
  alias ExSlp.Client
  import ExSlp.Util, only: [ parse_url: 1 ]

  @service "exslp"

  @doc """
  Registers a new SLP service with type `exslp` using
  the current Node name as the authority.
  Takes 2 optional keyword list parameters: slptool arguments
  and the service options.
  For more info on args see ExSlp.Server.register/3.
  For more info on opts see ExSlp.Server.register/3.
  Example: given the node name
      node@192.168.0.10
  the service URL will look like:
      service:exslp://node@192.168.0.10.
  After being registered the node might be discovered by
  service type `exslp`.
  Make sure to call ExSlp.deregister/3 before the app termination
  in order to cancel the registration.
  slptool always use net.slp.watchRegistrationPID = false option
  to connect slpd.
  Returns
      { :ok, resp } in case of success
      { :error, message } otherwise.
  """
  def register, do: register([], [])
  def register( opts ), do: register( [], opts )
  def register( args, opts ) do
    Server.register( service_url(), args, opts )
  end

  @doc """
  Checks whether the current node has been registered
  as a service.
  Takes 2 optional arguments: a keyword list of slptool
  arguments and a keyword list of findsrvs command options.
  Returns true if the authority of the current node
  has been found in the list of the services.
  """
  def registered?, do: registered?( [], [] )
  def registered?( opts ), do: registered?( [], opts )
  def registered?( args, opts ) do
    case res = Client.findsrvs( @service, args, opts ) do
      { :ok, result } ->
        my_authority = Atom.to_string Node.self
        result
          |> Enum.map( fn( url ) ->
            Map.get( parse_url( url ), :authority )
          end )
          |> Enum.member?( my_authority )
      _ -> res
    end
  end

  @doc """
  Cancells the service registration initialized by
  ExSlp.Service.register command.
  Takes an optional list of slptool command arhuments.
  Make sure to call the method before the app termination.
  The service would remain registered otherwise.
  Returns:
      { :ok, :resp } in case of success
      { :error, message } otherwise.
  """
  def deregister, do: deregister([])
  def deregister( args ) do
    Server.deregister( service_url(), args )
  end

  @doc """
  Sends a lookup multicast/broafcast(depends on the slpd settings,
  check net.slp.isBroadcastOnly property) request and returns the
  list of the registered `exslp` services.
  Takes 2 optional keyword list parameters: slptool arguments
  and the service options.
  For more info on args see ExSlp.Server.register/3.
  For more info on opts see ExSlp.Server.register/3.
  Returns an array of the refistered service URLs filtering
  out the current node authority.
  Example:
  Given there are 2 nodes one@192.168.0.10 and two@192.168.0.20.
  Each registers itself as an exslp service.
  For node one the method returns
      ["service:exslp://two@192.168.0.20,65535"]
  For node two the metod returns
      ["service:exslp://one@192.168.0.10,65535"]
  The URLs returned are accepted as `service_url` parameter
  in ExSlp.Service.connect/1 method.
  """
  def discover, do: discover([], [])
  def discover( opts ), do: discover( [], opts )
  def discover( args, opts ) do
    case res = Client.findsrvs( @service, args, opts ) do
      { :ok, result } ->
        my_authority = Atom.to_string Node.self
        result
          |> Enum.reject( fn( url ) ->
            Map.get( parse_url( url ), :authority ) == my_authority
          end )
      _ -> res
    end
  end

  @doc """
  Connects the 2 erlang nodes using the native Node.connect method.
  Takes `service_url` parameter which is either a regular node url
  or the fully qualified URL returned by ExSlp.Service.discover.
  Returns: see Node.connect/1.
  """
  def connect( service_url ) do
    %URI{ authority: authority } = parse_url( service_url )
    Node.connect String.to_atom( authority )
  end

  def service_url, do: service_url Node.self

  def service_url( node, service \\ @service ) do
    "service:#{service}://#{node}"
  end

end

