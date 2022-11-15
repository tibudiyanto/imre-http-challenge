defmodule Http do
  require Logger
  require TCPParser

  def accept(port) do
    case :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("Listening on port #{port}")
        loop_acceptor(socket)

      {:error, reason} ->
        Logger.error("Failed to listen on port #{port}: #{inspect(reason)}")
    end
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Http.TaskSupervisor, fn -> serve(client) end)

    :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        TCPParser.parse(data)

      {:error, :closed} ->
        :closed
    end
  end

  defp write_line(:ok, socket) do
    :gen_tcp.send(socket, "HTTP/1.1 200 OK\r\n")
    :gen_tcp.send(socket, "Content-Type: text/html\r\n")
    :gen_tcp.send(socket, "\r\n")
    :gen_tcp.send(socket, "ola \r\n")
    :gen_tcp.close(socket)
  end
end
