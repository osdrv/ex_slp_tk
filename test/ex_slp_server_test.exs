defmodule ExSlpServerTest do
  use ExUnit.Case

  alias ExSlp.Server

  doctest ExSlp.Server

  test "sys_status returns { { :ok, _status }, { :ok, _status } } if the toolkit is installed and the server is running" do
    assert { { :ok, _ }, { :ok, pid } } = Server.sys_status
    assert is_integer( pid )
  end

  test "register with correct url and without options and attrs" do
    service = "test_service://localhost"
    assert { :ok, _ } = Server.server_status
    assert { :ok, _ } = Server.register( service )
    assert { :ok, _ } = Server.deregister( service )
  end

  test "register with complete correct url and without options and attrs" do
    service = "service:test_service://localhost"
    assert { :ok, _ } = Server.server_status
    assert { :ok, _ } = Server.register( service )
    assert { :ok, _ } = Server.deregister( service )
  end

  test "register with incorrect url" do
    service = "service:"
    assert { :ok, _ } = Server.server_status
    assert { :ok, _ } = Server.register( service )
    assert { :ok, resp } = Server.deregister( service )
  end

end

