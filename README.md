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
Given 2 erlang nodes running. We want to connect the nodes with no prior knowledge of each other.

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

#### Dependencies:
  * libslp  v2.0+
  * slptool v2.0+
  * Elixir  v1.2+
