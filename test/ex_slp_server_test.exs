defmodule ExSlpServerTest do
  use ExUnit.Case
  doctest ExSlp.Server

  test "sys_status returns {:ok, :running} if the toolkit is installed and the server is running" do
    assert { { :ok, _ }, { :ok, pid } } = ExSlp.Server.sys_status
    assert is_integer( pid )
  end

end

