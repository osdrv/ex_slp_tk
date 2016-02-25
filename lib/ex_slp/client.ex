defmodule ExSlp.Client do

  alias ExSlp.Tool
  import ExSlp.Util, only: [
    format_servise_url: 1,
           format_args: 1,
           format_opts: 1,
            parse_opts: 1
  ]

  def findsrvs( service ), do: findsrvs( service, [], [] )

  def findsrvs( service, opts ), do: findsrvs( service, [], opts )

  def findsrvs( service, args, opts ) do
    args = format_args args
    opts = format_opts opts
    case res = Tool.exec_cmd( args, :findsrvs, [ format_servise_url( service ), opts ]) do
      { :ok, result } -> { :ok, String.split( result, "\n" ) }
      _ -> res
    end
  end

  def findattrs( url ), do: findattrs( url, [], [] )

  def findattrs( url, opts ), do: findattrs( url, [], opts )

  def findattrs( url, args, opts ) do
    args = format_args args
    opts = format_opts opts
    case res = Tool.exec_cmd( args, :findattrs, [ format_servise_url( url ), opts ]) do
      { :ok, result } ->
        { :ok, parse_opts( result ) }
      _ -> res
    end

  end

  def findsrvtypes, do: findsrvtypes( nil, [] )

  def findsrvtypes( authority ), do: findsrvtypes( authority, [] )

  def findsrvtypes( authority, args ) do
    args = format_args args
    opts = case authority do
      nil -> []
      _   -> [ authority ]
    end
    case res = Tool.exec_cmd( args, :findsrvtypes, opts ) do
      { :ok, result } ->
        { :ok, String.split( result, "\n" ) }
      _ -> res
    end

  end

  def findscopes( args ) do
    args = format_args args
    case res = Tool.exec_cmd( args, :findscopes ) do
      { :ok, result } ->
        { :ok, String.split( result, "\n" ) }
      _ -> res
    end
  end

  def getproperty( property ), do: getproperty( property, [] )

  def getproperty( property, args ) do
    args = format_args args
    case res = Tool.exec_cmd( args, :getproperty, [ property ] ) do
      { :ok, response } ->
        { :ok, String.replace( response, "#{property} = ", "" ) }
      _ -> res
    end
  end

end

