defmodule WalkaroundWeb.TransitionsTestLive do
  use WalkaroundWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       endpoint: WalkaroundWeb.Endpoint,
       current_view: "2n",
       previous_view: "2n",
       animation_class: "",
       all_views: ~w(1en 1es 1n 1s 1w 2e 2n 2np 2s 2w)
     })}
  end

  def handle_event("go_to_view", params, socket) do
    view = params["view"]
    animation_class = params["animation-class"]
    IO.puts("Setting current_view to #{view}.")

    socket =
      assign(socket, %{
        current_view: view,
        previous_view: socket.assigns.current_view,
        animation_class: animation_class
      })

    {:noreply, socket}
  end
end
