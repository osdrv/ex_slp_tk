defmodule ExSlp.Server do

  @slptool "slptool"
  @slpd    "slpd"

  def sys_status do
    { toolkit_status(), server_status() }
  end

  def toolkit_status do
    case System.find_executable(@slptool) do
      nil -> { :cmd_unknown, "The command #{@slptool} could not be found. Check your $PATH ENV variable." }
      path ->
        path = String.strip( path )
        case System.cmd( "test", [ "-x", path ] ) do
          { "", 0 } -> { :ok, "System is running." }
          { "", 1 } -> { :not_executable, "The file #{path} is not executable for the current user." }
          { error, error_code } -> { :error, error, error_code }
        end
      { error, error_code } -> { :error, error, error_code }
    end
  end

  def server_status do
    case :os.cmd( :"ps cax | grep #{@slpd} | awk '{print $1}'" ) do
      []  -> { :not_running, "The server doesn't seem to be running." }
      output ->
        pid = output |> List.to_string |> String.strip |> String.to_integer
        { :ok, pid }
    end
  end

end

