defmodule Discovery.Mixfile do
  use Mix.Project

  def project do
    [app: :discovery,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      applications: [:logger],
      mod: { Discovery.App, [[]] }
    ]
  end

  defp deps do
    [
      { :ex_slp, "~> 0.1.0" },
    ]
  end
end
