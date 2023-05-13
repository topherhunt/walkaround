defmodule WalkaroundWeb.TransitionsTestLive do
  use WalkaroundWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       endpoint: WalkaroundWeb.Endpoint,
       current_view: "2n",
       previous_view: "2n",
       animation_class: ""
     })}
  end

  def handle_event("go_to_view", params, socket) do
    view = params["view"]
    animation_class = params["animation-class"]

    socket =
      assign(socket, %{
        previous_view: socket.assigns.current_view,
        current_view: view,
        animation_class: animation_class
      })

    # IO.puts("Animation: #{socket.assigns.animation}")

    {:noreply, socket}
  end
end
