defmodule ExSlp.Util do
  
  def format_servise_url( service ) do
    case Regex.run( ~r/^service\:/, service ) do
      nil -> "service:#{service}"
      _   -> service
    end
  end

  def format_args( args ) do
    Enum.map( args, fn({ k, v }) -> [ "-#{k}", "#{v}" ] end ) |> List.flatten
  end

  def format_opts( opts ) do
    case res = Enum.map( opts, fn({ k, v }) -> "(#{k}=#{v})" end ) |> Enum.join(",") do
      "" -> res
      _ -> "\"#{res}\""
    end
  end

  def parse_opts( opts_s ) do
    Regex.scan( ~r/\((.+)=(.+)\)/U, opts_s )
      |> Enum.map( fn([ _, k, v ]) -> { k, v } end )
  end

end

