defmodule ExSlp.Tool do

  @slptool "slptool"

  def status do
    case System.find_executable(@slptool) do
      nil -> { :cmd_unknown, "The command #{@slptool} could not be found. Check your $PATH ENV variable." }
      { error, error_code } -> { :error, error, error_code }
      path ->
        path = String.strip( path )
        case System.cmd( "test", [ "-x", path ] ) do
          { "", 0 } -> { :ok, "The toolkit is set up." }
          { "", 1 } -> { :not_executable, "The file #{path} is not executable for the current user." }
          { error, error_code } -> { :error, error, error_code }
        end
    end
  end

  def exec_cmd( args, cmd, opts ) do
    case System.cmd( @slptool, args ++ [ cmd | opts ] ) do
      { res, 0 } ->
        { :ok, res |> String.strip }
      { err, 1 } -> { :error, err |> String.strip }
    end
  end

end

