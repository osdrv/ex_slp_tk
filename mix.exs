defmodule ExSlp.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :ex_slp,
      version:         "0.1.1",
      elixir:          "~> 1.1",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps:            deps,
      description:     description,
      package:         package,
   ]
  end

  def application do
    [
      applications: [:logger]
    ]
  end

  defp deps do
    [
      { :ex_doc,  "~> 0.11"  },
      { :earmark, ">= 0.0.0" },
    ]
  end

  defp description do
    """
    Zero-config local network Elixir/Erlang node discovery lib.
    Allows an Elixir node to register itself as a local netowrk service and discover the orher registered services.
    """
  end


  defp package do
    [
      files:       ~w/lib mix.exs README* LICENSE*/,
      licenses:    ~w/MIT/,
      maintainers: [ "Oleg S" ],
      links: %{
        "GitHub" => "https://github.com/4pcbr/ex_slp_tk",
      },
    ]
  end

end
