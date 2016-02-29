defmodule ExSlp.Util do
  
  @doc """
  Formats the service url and makes it look like:
  service:myservice://...
  """
  def format_servise_url( service ) do
    case Regex.run( ~r/^service\:/, service ) do
      nil -> "service:#{service}"
      _   -> service
    end
  end

  @doc """
  Takes a keyword list and formats it as a command line arguments like:
  [ "-arg1", "val1", "-arg2", "val2", ... ]
  """
  def format_args( args ) do
    Enum.map( args, fn({ k, v }) -> [ "-#{k}", "#{v}" ] end ) |> List.flatten
  end

  @doc """
  Takes a keyword list and formats it as slptool opts list:
  "(arg1=val1),(arg2=val2)"
  """
  def format_opts( opts ) do
    case res = Enum.map( opts, fn({ k, v }) -> "(#{k}=#{v})" end ) |> Enum.join(",") do
      "" -> res
      _ -> "\"#{res}\""
    end
  end

  @doc """
  Takes a string of slptool opts and returns a keyword list. 
  """
  def parse_opts( opts_s ) do
    Regex.scan( ~r/\((.+)=(.+)\)/U, opts_s )
      |> Enum.map( fn([ _, k, v ]) -> { k, v } end )
  end

  @doc """
  The normal URI.parse which truncates the "service:" preffix and
  the lifetime postfix.
  """
  def parse_url( url ) do
    [ url, _ttl ] = url |> String.replace( ~r/^service\:/, "" ) |> String.split(",")
    URI.parse( url )
  end

  @doc """
  Compacts an Enumerable instance.
  """
  def compact([]), do: []
  def compact([ el | tail ]) do
    if el != "" && el != nil && el != 0 && el != false do
      [ el | compact( tail ) ]
    else
      compact( tail )
    end
  end

end

