# ExSlp

This is an Elixir binding for OpenSLP toolkit.

#### What is SLP and why it's useful

Wiki says:
  "The Service Location Protocol (SLP, srvloc) is a service discovery protocol that allows computers and other devices to find services in a local area network without prior configuration. SLP has been designed to scale from small, unmanaged networks to large enterprise networks."

The protocol is being used in almost all the modern printers and local network shared services which are able to be discovered and connected with zero config e.g. Apple Bonjour, iTunes shared folders, etc.

The protocol applicability is really wide and might be used in almost any local netowrk.

#### About this library
This library is basically a binding for [slptool unix command](http://manpages.ubuntu.com/manpages/gutsy/man1/slptool.1.html) which is a part of [openslp project](http://www.openslp.org/).

The library provides some base modules which extend the distributed nature of Elixir by providing the zero-conf functionality.

#### Example:
Given 2 Erlang nodes running. We want to connect the nodes with no prior knowledge of each other.

Node one:

```elixir
iex(one@127.0.0.1)1> Node.self
:"one@127.0.0.1"
iex(one@127.0.0.1)2> Node.list
[]
```

Node two:

```elixir
iex(two@127.0.0.1)1> Node.self
:"two@127.0.0.1"
iex(two@127.0.0.1)2> Node.list
[]
```

Let's register the services:

```elixir
iex(one@127.0.0.1)3> ExSlp.Service.register
{:ok, ""}
```

Node two:

```elixir
iex(two@127.0.0.1)3> ExSlp.Service.register
{:ok, ""}
```

Everything is ready for the discovery. Running:

```elixir
iex(one@127.0.0.1)4> ExSlp.Service.discover
["service:exslp://two@127.0.0.1,65535"]
```

One could see node one received the information about node 2 without any clue it exists.

Let's connect 'em:

```elixir
iex(two@127.0.0.1)4> ExSlp.Service.discover |> List.first |> ExSlp.Service.connect
true
iex(two@127.0.0.1)5> Node.list
[:"one@127.0.0.1"]
```

Node one says:

```elixir
iex(one@127.0.0.1)5> Node.list
[:"two@127.0.0.1"]
```

This is it. 2 erlang/elixir nodes are connected and we did it using a network multicast request.

For more examples check out `examples` folder.

#### Dependencies:

Basic requirements are

  * libslp  v1.2+
  * slptool v1.2+
  * Elixir  v1.1+

To install OpenSLP  on debian-based systems something like this should do the trick:

    sudo apt-get install slptool slpd libslp1
    sudo /etc/init.d/slpd restart

You could also use a docker image like [vcrhonek/openslp](https://hub.docker.com/r/vcrhonek/openslp/).  To run slpd as a daemon, you'll need a command like this:

    docker run -d -p 427:427/tcp -p 427:427/udp --name openslp vcrhonek/openslp


#### Settings:

By default the ex_slp library will interact with the "slptool" command by assuming it is available as "slptool".  To change the details of that invocation, just add a section like this to your `config.exs` file:

    config :ex_slp,
      slptool: "/some/path/to/slptool"

Or, you could invoke slptool with [a docker image](https://hub.docker.com/r/vcrhonek/openslp/):

    config :ex_slp,
      slptool: "docker run --rm vcrhonek/openslp slptool"

#### Testing

Test suite is slp toolkit version sensitive.

One could check the toolkit version running: `slptool -v`.

Depending on the version one should disable version-specific tests, as:

```
slptool -v
> slptool version = 2.0.0
> libslp version = 2.0.0
> libslp configuration file = /usr/local/Cellar/openslp/2.0.0/etc/slp.conf
mix test --exclude v1
> ...
> Finished in 3.0 seconds (0.3s on load, 2.7s on tests)
```

Version 1 does not support extended command arguments as: interfaces and unicastic requests. Unicastic option allows you to query the local network interface only. Without this option slptool will send a multicast request to the local network and therefore running the test suit takes a while.

#### Known problems
  - `slptool findsrvtypes` might kill slpd on versions prior to 2.0.0
