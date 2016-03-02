defmodule ExSlpServiceTest do
  use ExUnit.Case
  import ExSlp.Service

  alias ExSlp.Server
  alias ExSlp.Client

  test "`register` registers an exslp service and successfully deregisters" do
    assert { :ok, _ } = Server.status
    args = [ u: "127.0.0.1" ]
    assert { :ok, results } = Client.findsrvs( "exslp", args, [] )
    my_service = "service:exslp://#{Node.self},65535"
    assert ( ! Enum.member?( results, my_service ) )
    register
    assert { :ok, results } = Client.findsrvs( "exslp", args, [] )
    assert Enum.member?( results, my_service )
    deregister
    assert { :ok, results } = Client.findsrvs( "exslp", args, [] )
    assert ( ! Enum.member?( results, my_service ) )
  end

  test "registered? returns false for an unregistered service" do
    args = [ u: "127.0.0.1" ]
    assert { :ok, _ } = Server.status
    assert registered?( args, [] ) == false
  end

  test "registered? returns true for a registered node" do
    assert { :ok, _ } = Server.status
    args = [ u: "127.0.0.1" ]
    register
    assert registered?( args, [] ) == true
    deregister
    assert registered?( args, [] ) == false
  end

end

