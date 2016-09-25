defmodule Discovery do

  use GenServer
  require Logger

  alias ExSlp.Service

  @discover_timeout 10_000

  if Mix.env == :test do
    @slp_args [ u: "127.0.0.1" ]
  else
    @slp_args []
  end

  def start_link( state ) do
    res = { :ok, _ } = GenServer.start_link( __MODULE__, state, name: __MODULE__ )
    Logger.info "Discovery application started"
    Process.send( __MODULE__, :discover, [] )
    res
  end

  def update( services ) do
    GenServer.cast( __MODULE__, { :update, services } )
  end

  def get_services do
    GenServer.call( __MODULE__, :get_services )
  end

  def handle_info( :discover, state ) do
    Logger.debug "Discovery.discover round is up"
    case Service.registered?( @slp_args, [] ) do
      false ->
        { :ok, _ } = Service.register
      _ -> nil
    end
    Service.discover( @slp_args, [] )
      |> ensure_connnected
    Process.send_after( __MODULE__, :discover, @discover_timeout )
    { :noreply, state }
  end

  def handle_cast({ :update, services }, _state ) do
    Enum.each(services, fn service ->
      Service.connect(service)
    end)
    Logger.info "Connected node list: #{inspect Node.list}"
    { :noreply, :ordsets.from_list( services ) }
  end

  def handle_call( :get_services, _from, state ) do
    { :reply, state, state }
  end

  def handle_info({ :DOWN, _ref, :process, _pid, _reason }, state ) do
    Service.deregister
    Logger.info "Discovery application terminates"
    { :noreply, state }
  end

  def terminate( _reason, state ) do
    IO.puts "deregister service"
    Service.deregister
  end

  defp ensure_connnected( services ) do
    Logger.debug "Ensure connected: #{inspect services}"
    update( services )
  end

end
