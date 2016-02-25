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
    assert Enum.member?( real_res, expected_res )
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

  test "Should find an attribute of a registered service" do
    service = "myservice://localhost"
    args = [ u: "localhost" ]
    opts = [ v: 1.01, cluster: :generic, special: "none" ]
    expected_res = [{ "v", "1.01" }, { "cluster", "generic" }, { "special", "none" }]
    assert { :ok, _ } = Server.status
    assert { :ok, _ } = Server.register( service, [], opts )
    assert { :ok, real_res } = findattrs( service, args, [] )
    assert real_res == expected_res
    assert { :ok, _ } = Server.deregister( service )
  end

  test "Should get the list of the registered servives" do
    service_type1 = "myservice1"
    service_type2 = "myservice2"
    args = [ u: "localhost" ]
    assert { :ok, _ } = Server.status
    assert { :ok, _ } = Server.register( "#{service_type1}://localhost" )
    assert { :ok, _ } = Server.register( "#{service_type2}://localhost" )
    assert { :ok, real_res } = findsrvtypes( nil, args )
    assert Enum.member?( real_res, "service:#{service_type1}" )
    assert Enum.member?( real_res, "service:#{service_type2}" )
    assert { :ok, _ } = Server.deregister( "#{service_type1}://localhost" )
    assert { :ok, _ } = Server.deregister( "#{service_type2}://localhost" )
  end

  test "Should get the list of the registered services with affinity" do
    service_type1 = "myservice1.aff1"
    service_type2 = "myservice2.aff2"
    args = [ u: "localhost" ]
    assert { :ok, _ } = Server.status
    assert { :ok, _ } = Server.register( "#{service_type1}://localhost" )
    assert { :ok, _ } = Server.register( "#{service_type2}://localhost" )
    assert { :ok, real_res1 } = findsrvtypes( "aff1", args )
    assert Enum.member? real_res1, "service:#{service_type1}"
    assert Enum.member?( real_res1, "service:#{service_type2}" ) == false
    assert { :ok, _ } = Server.deregister( "#{service_type1}://localhost" )
    assert { :ok, _ } = Server.deregister( "#{service_type2}://localhost" )
  end

  test "findscopes finds registered scopes" do
    args = [ u: "localhost" ]
    assert { :ok, _ } = Server.status
    assert { :ok, real_res } = findscopes( args )
    assert String.contains? real_res, "DEFAULT"
  end

  test "getproperty returns the value" do
    assert { :ok, _ } = Server.status
    assert { :ok, response } = getproperty( "net.slp.useScopes" )
    assert response == "DEFAULT"
  end

end

