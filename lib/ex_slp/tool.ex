defmodule ExSlp.Tool do

  @slptool "slptool"

  @doc """
  Checks the status of `slptool` on the current system.
  Returns:
      { :ok, message } # in case of success
      { :not_executable, message }
      # in case the tool is installed but is not executable by the current user
      { :error, message } # otherwise
  """
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

  @doc """
  Executes `slptool` command `cmd` with `args` as
  command arguments and `opts` as the list of post-command options.
  Returns:
      { :ok, response } # in case of success,
      { :error, message } # otherwise.
  """
  def exec_cmd( args, cmd ), do: exec_cmd( args, cmd, [] )
  def exec_cmd( args, cmd, opts ) do
    case System.cmd( @slptool, args ++ [ cmd | opts ] ) do
      { res, 0 } ->
        { :ok, res |> String.strip }
      { err, 1 } -> { :error, err |> String.strip }
    end
  end

  def version do
    case exec_cmd( [], "-v" ) do
      { :ok, res } ->
        case String.split( res, "\n" )
          |> Enum.filter( fn str ->
            Regex.match?( ~r/slptool\sversion/, str )
          end )
          |> List.first do
            nil -> nil
            version_str ->
              case Regex.run( ~r/([\d\.]+)$/, version_str ) do
                nil -> nil
                [ _, ver ] -> ver |> String.split(".")
                                  |> Enum.map( &String.to_integer/1 )
                                  |> List.to_tuple
                _ -> nil
              end
          end
      _ -> nil
    end
  end

end

