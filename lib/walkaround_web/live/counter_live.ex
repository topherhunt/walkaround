defmodule WalkaroundWeb.CounterLive do
  use WalkaroundWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{count: 0})}
  end

  def handle_event("incr_count", %{"value" => amount}, socket) do
    amount = String.to_integer(amount)
    IO.puts("incr_count by: #{amount}")
    {:noreply, assign(socket, :count, socket.assigns.count + amount)}
  end
end
