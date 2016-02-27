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

  test "format should return formatted args" do
    args = [ v: 1.01, s: "test_scope1", l: :en, t: 123, i: "10.77.13.240,192.168.250.240", u: "10.77.13.237" ]
    assert format_args( args ) == ["-v", "1.01", "-s", "test_scope1", "-l", "en", "-t", "123", "-i", "10.77.13.240,192.168.250.240", "-u", "10.77.13.237"]
  end

  test "format_opts should return a formatted string" do
    opts = [ v: 1.01, cluster: :generic, special: "none" ]
    assert format_opts( opts ) == "\"(v=1.01),(cluster=generic),(special=none)\""
  end

  test "parse_opts should return the keyword list" do
    assert parse_opts("\"(v=1.01),(cluster=generic),(special=none)\"") ==
      [{ "v", "1.01" }, { "cluster", "generic" }, { "special", "none" }]
  end

  test "parse_url should return a keyword list" do
    url = "service:myservice://127.0.0.1:8080,65535"
    assert parse_url( url ) == %URI{
      authority: "127.0.0.1:8080",
       fragment: nil,
           host: "127.0.0.1",
           path: nil,
           port: 8080,
          query: nil,
         scheme: "myservice",
       userinfo: nil,
    }
  end

  test "compact should remove all the empty elements from the array" do
    arr = [ nil, 1, -1, "0", 0, "", [], %{}, {} ]
    assert compact( arr ) == [ 1, -1, "0", [], %{}, {} ]
  end

end

