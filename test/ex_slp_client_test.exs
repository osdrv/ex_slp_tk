defmodule ExSlpClientTest do
  use ExUnit.Case
  import ExSlp.Client

  alias ExSlp.Server

  test "Should find a registered service with no search filters" do
    assert { :ok, _ } = Server.status
    service_type = "myservice"
    service = "#{service_type}://localhost"
    args = [ u: "localhost" ]
    expected_res = "service:#{service},65535"
    assert { :ok, _ } = Server.register( service )
    assert { :ok, real_res } = findsrvs( service_type, args, [] )
    assert expected_res == real_res
    assert { :ok, _ } = Server.deregister( service )
  end

  @tag skip: "slptool sometimes fails to find a service with a given attribute"
  test "Should find a registered service with search filters" do
    assert { :ok, _ } = Server.status
    service_type = "myservice"
    service = "#{service_type}://localhost"
    expected_res = "service:#{service},65535"
    args = [ u: "localhost" ]
    opts = [ v: 1.01 ]
    assert { :ok, _ } = Server.register( service, [], opts )
    assert { :ok, real_res } = findsrvs( service_type, args, opts )
    assert expected_res == real_res
    assert { :ok, _ } = Server.deregister( service )
  end


end

