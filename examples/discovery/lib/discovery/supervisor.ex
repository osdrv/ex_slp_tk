defmodule Discovery.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    children= [
      worker( Discovery, args ),
    ]
    opts= [ strategy: :one_for_one ]

    supervise( children, opts )
  end

end
