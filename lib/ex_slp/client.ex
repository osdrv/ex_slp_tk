defmodule ExSlp.Client do

  alias ExSlp.Tool
  import ExSlp.Util, only: [
    format_servise_url: 1,
           format_args: 1,
           format_opts: 1,
            parse_opts: 1,
               compact: 1,
  ]

  @doc """
  Sends a multicast/broadcast service discovery request
  to the local network.
  Takes `service_type` as a mandatory parameter,
  `args` and `opts` keyword lists as optional arguments.
  Allowed `args` keys:
      s: scopes, a comma-separated list of scopes
      l: language tag
      t: lifetame tag
      i: a comma-separated list of interfaces
      u: specifies a single interface
  `opts`
  Returns:
      { :ok, [ ( service_url1(, service_url2(, ...) ) ) ] } # in case of success,
      { :error, message } # otherwise.
  Examples:
      findsrvs( "myservice" )
      findsrvs( "service:myservice", [ attr1: value1, attr2: value2 ] )
      findsrvs( "myservice", [ i: "10.77.13.240,192.168.250.240" ], [] )
      findsrvs( "service:myservice", [ u: "10.77.13.237" ], [ attr1: value1 ] )
  See http://www.openslp.org/doc/html/ProgrammersGuide/SLPFindSrvs.html
  for more method internals.
  """
  def findsrvs( service_type ), do: findsrvs( service_type, [], [] )
  def findsrvs( service_type, opts ), do: findsrvs( service_type, [], opts )
  def findsrvs( service_type, args, opts ) do
    args = format_args args
    opts = format_opts opts
    case res = Tool.exec_cmd( args, :findsrvs, [ format_servise_url( service_type ), opts ]) do
      { :ok, result } -> { :ok, String.split( result, "\n" ) |> compact }
      _ -> res
    end
  end

  @doc """
  Returns the list of the attributes specified for the service
  url provided.
  Takes `service_url` as a mandatory parameter,
  `args` and `opts` keyword lists as optional arguments.
  See ExSlp.Client.findsrvs/3 for details on `args` and `opts`.
  Returns:
      { :ok, [ ( { "key1", "val1" }(, { "key2", "val2 }(, ... ) ) ) ] # in case of success,
      { :error, message } # otherwise.
  Example:
      > ExSlp.Server.register("myservice://127.0.0.1", [ attr1: "val1", attr2: "val2" ])
      {:ok, ""}
      > ExSlp.Client.findattrs("service:myservice://127.0.0.1")
      {:ok, [{"attr1", "val1"}, {"attr2", "val2"}]}
  """
  def findattrs( service_url ), do: findattrs( service_url, [], [] )
  def findattrs( service_url, opts ), do: findattrs( service_url, [], opts )
  def findattrs( service_url, args, opts ) do
    args = format_args args
    opts = format_opts opts
    case res = Tool.exec_cmd( args, :findattrs, [ format_servise_url( service_url ), opts ]) do
      { :ok, result } ->
        { :ok, parse_opts( result ) }
      _ -> res
    end
  end

  @doc """
  Sends a discovery request and fetched all the services
  registered in the network.
  Takes `authority` and `args` as optional arguments.
  `authority` is a string identifying the service.
  `args` is a regular slptool keyword list, see ExSlp.Client.findsrvs/3
  for more details.
  Returns:
      { :ok, [ ( service_type1(, service_type2(, ...) ) ) ] # in case of success,
      { :error, message } # otherwise.
  Example:
      > ExSlp.Server.register "myservice1://127.0.0.1"
      {:ok, ""}
      > ExSlp.Server.register "myservice2://127.0.0.1"
      {:ok, ""}
      > ExSlp.Client.findsrvtypes
      {:ok, ["service:myservice1", "service:myservice2"]}
      > ExSlp.Server.register "myservice3.x://127.0.0.1"
      {:ok, ""}
      > ExSlp.Client.findsrvtypes "x" # Note: we provide the authority here
      {:ok, ["service:myservice3.x"]}
  """
  def findsrvtypes, do: findsrvtypes( nil, [] )
  def findsrvtypes( authority ), do: findsrvtypes( authority, [] )
  def findsrvtypes( authority, args ) do
    args = format_args args
    opts = case authority do
      nil -> []
      _   -> [ authority ]
    end
    case res = Tool.exec_cmd( args, :findsrvtypes, opts ) do
      { :ok, result } ->
        { :ok, String.split( result, "\n" ) |> compact }
      _ -> res
    end

  end

  @doc """
  Finds all the scopes specified by the services.
  Takes a standard `args` keyword list.
  Returns:
      { :ok, [ ( scope1(, scope2(, ...) ) ) ] # in case of success,
      { :error, message } # otherwise.
  """
  def findscopes, do: findscopes([])
  def findscopes( args ) do
    args = format_args args
    case res = Tool.exec_cmd( args, :findscopes ) do
      { :ok, result } ->
        { :ok, String.split( result, "\n" ) |> compact }
      _ -> res
    end
  end

  @doc """
  Reads the property of the local service.
  Takes a mandatory `property` parameter and `args` as a list of
  slptool arguments.
  Returns:
      { :ok, property_value } # in case of success,
      { :error, message } # otherwise.
  """
  def getproperty( property ), do: getproperty( property, [] )
  def getproperty( property, args ) do
    args = format_args args
    case res = Tool.exec_cmd( args, :getproperty, [ property ] ) do
      { :ok, response } ->
        { :ok, String.replace( response, "#{property} = ", "" ) }
      _ -> res
    end
  end

end

