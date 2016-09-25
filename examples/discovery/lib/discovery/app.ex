defmodule Discovery.App do
  use Application

  def start(_type, args) do
    Discovery.Supervisor.start_link(args)
  end

end
