defmodule ExSlpServerTest do
  use ExUnit.Case

  import ExSlp.Server

  doctest ExSlp.Server

  test "status() returns { :ok, _status } if the server is running" do
    assert { :ok, pid } = status
    assert is_integer( pid )
  end

  test "register with incorrect url" do
    service = "service:"
    assert { :ok, _ } = status
    assert { :error, error } = register( service )
    assert Regex.run( ~r/^Invalid\sURL/, error ) != nil
    assert { :error, _dereg_error } = deregister( service )
  end

  test "register with correct url and without options and attrs" do
    service = "test_service://localhost"
    assert { :ok, _ } = status
    assert { :ok, _ } = register( service )
    assert { :ok, _ } = deregister( service )
  end

  test "register with complete correct url and without options and attrs" do
    service = "service:test_service://localhost"
    assert { :ok, _ } = status
    assert { :ok, _ } = register( service )
    assert { :ok, _ } = deregister( service )
  end

  test "register with correct url, without options and with attrs" do
    service = "test_service://localhost"
    attrs = [ v: 1.01, cluster: :generic, special: "none" ]
    assert { :ok, _ } = status
    assert { :ok, _ } = register( service, attrs )
    assert { :ok, _ } = deregister( service )
  end

  test "register with correct url, with options and attrs" do
    service = "test_service://localhost"
    opts = [ l: :en, t: 1024 ]
    args = [ v: 1.01, cluster: :generic, special: "none" ]
    assert { :ok, _ } = status
    assert { :ok, _ } = register( service, opts, args )
    assert { :ok, _ } = deregister( service, args )
  end

end

