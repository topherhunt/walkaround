defmodule WalkaroundWeb.TransitionsTestLive do
  use WalkaroundWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{endpoint: WalkaroundWeb.Endpoint, view: "2n"})}
  end

  def handle_event("go_to_view", %{"view" => view}, socket) do
    {:noreply, assign(socket, :view, view)}
  end
end
