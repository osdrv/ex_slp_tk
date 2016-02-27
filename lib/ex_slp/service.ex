defmodule ExSlp.Service do
  alias ExSlp.Server
  alias ExSlp.Client
  import ExSlp.Util, only: [ parse_url: 1 ]

  @service "exslp"
  @ttl     65535

  def register, do: register([], [])
  def register( opts ), do: register( [], opts )
  def register( args, opts ) do
    Server.register( service_url, args, opts )
  end

  def deregister, do: deregister([])
  def deregister( args ) do
    Server.deregister( service_url, args )
  end

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

  def connect( service_url ) do
    %URI{ authority: authority } = parse_url( service_url )
    Node.connect String.to_atom( authority )
  end

  defp service_url do
    "service:#{@service}://#{Node.self}"
  end

end

