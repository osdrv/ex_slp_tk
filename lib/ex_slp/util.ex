defmodule ExSlp.Util do
  
  def format_servise_url( service ) do
    case Regex.run( ~r/^service\:/, service ) do
      nil -> "service:#{service}"
      _   -> service
    end
  end

end

