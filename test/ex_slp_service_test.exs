defmodule ExSlpServiceTest do
  use ExUnit.Case
  import ExSlp.Service

  alias ExSlp.Server
  alias ExSlp.Client

  test "`register` registers an exslp service and successfully deregisters" do
    assert { :ok, _ } = Server.status
    args = case ExSlp.Tool.version do
      { 1, _, _ } -> []
      { 2, _, _ } -> [ u: "127.0.0.1" ]
    end
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
    args = case ExSlp.Tool.version do
      { 1, _, _ } -> []
      { 2, _, _ } -> [ u: "127.0.0.1" ]
    end
    assert { :ok, _ } = Server.status
    assert registered?( args, [] ) == false
  end

  test "registered? returns true for a registered node" do
    assert { :ok, _ } = Server.status
    args = case ExSlp.Tool.version do
      { 1, _, _ } -> []
      { 2, _, _ } -> [ u: "127.0.0.1" ]
    end
    register
    assert registered?( args, [] ) == true
    deregister
    assert registered?( args, [] ) == false
  end

end

