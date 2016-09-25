# Discovery App

This is a basic mix application implementing an SLP node functionality.

#### App structure

```
├── discovery
│   ├── app.ex
│   └── supervisor.ex
└── discovery.ex
```

There are 2 supplementary modules: Discovery.App and Discovery.Supervisor which are pretty much stock app-specific boilerplate modules.

Discovery is a GenServer with a bunch of standard callbacks.

It all starts in start_link callback which immediately calls server method `discover`:

```elixir
16   def start_link( state ) do
17     res = { :ok, _ } = GenServer.start_link( __MODULE__, state, name: __MODULE__ )
18     Logger.info "Discovery application started"
19     Process.send( __MODULE__, :discover, [] )
20     res
21   end
```
Let's have a look on discover:

```elixir
31   def handle_info( :discover, state ) do
32     Logger.debug "Discovery.discover round is up"
33     case Service.registered?( @slp_args, [] ) do
34       false ->
35         { :ok, _ } = Service.register
36       _ -> nil
37     end
38     Service.discover( @slp_args, [] )
39       |> ensure_connnected
40     Process.send_after( __MODULE__, :discover, @discover_timeout )
41     { :noreply, state }
42   end
```
So, first we're checking whether we ensure the current node is registered and later send a broadcast discovery query. `Service.discover` responds synchronously and returns a list of discovered services (the list does not include the current node, see the docs).

```elixir
44   def handle_cast({ :update, services }, _state ) do
45     Enum.each(services, fn service ->
46       Service.connect(service)
47     end)
48     Logger.info "Connected node list: #{inspect Node.list}"
49     { :noreply, :ordsets.from_list( services ) }
50   end
```
Here is a dummy code that connects all the nodes out of the list.

#### Starting the app

In order to start the app and get 2 nodes connected run in your terminal (I assume you run 2 distinct sessions):

```bash
$1 iex --sname foo --cookie 123456 -S mix
$2 iex --sname bar --cookie 123456 -S mix
```

The application outputs some debug info and eventually you should see the nodes reporting connectivity between them:

```bash
$1 [info]  Connected node list: [:bar@myhost]
$2 [info]  Connected node list: [:foo@myhost]
```
In order to have a better idea what's going on insode the service consider reading the logs (depends on your slpd settings):

```bash
$3 tail -f /var/log/slpd.log
```
