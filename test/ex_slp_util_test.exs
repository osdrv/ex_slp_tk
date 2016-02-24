defmodule ExSlpUtilTest do
  use ExUnit.Case
  import ExSlp.Util

  test "Should not format the full service url" do
    full_url = "service:myservice://host"
    assert full_url == format_servise_url( full_url )
  end

  test "Should format the url if a shortened version provided" do
    url = "myservice://host"
    assert "service:#{url}" == format_servise_url( url )
  end

end

