# parsing HTTP requests from tcp sockets
defmodule TCPParser do
  require Logger

  def parse(data) do
    case String.split(data, "\r\n") do
      ["GET / HTTP/1.1" | _rest] ->
        :ok

      _ ->
        :notHttp
    end
  end
end
