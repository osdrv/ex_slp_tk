defmodule ExSlpToolTest do
  use ExUnit.Case
  import ExSlp.Tool

  test "status() Should report the status of the toolkit" do
    assert { :ok, "The toolkit is set up." } == status()
  end

end

