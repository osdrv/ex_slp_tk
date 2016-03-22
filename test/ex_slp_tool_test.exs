defmodule ExSlpToolTest do
  use ExUnit.Case
  import ExSlp.Tool

  test "status() Should report the status of the toolkit" do
    assert { :ok, "The toolkit is set up." } == status()
  end

  test "version() should return the tool version" do
    { major, minor, patch } = version()
    assert is_number major
    assert is_number minor
    assert is_number patch
  end


end

