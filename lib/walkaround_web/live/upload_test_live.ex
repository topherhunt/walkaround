defmodule WalkaroundWeb.UploadTestLive do
  use WalkaroundWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:image_red, accept: ~w(.jpg .jpeg), auto_upload: true)
      |> allow_upload(:image_blue, accept: ~w(.jpg .jpeg), auto_upload: true)

    {:ok, socket}
  end

  def handle_event("validate-image-upload", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref, "type" => color}, socket) do
    field =
      case color do
        "red" -> :image_red
        "blue" -> :image_blue
      end

    {:noreply, cancel_upload(socket, field, ref)}
  end

  # def handle_event("go_to_view", params, socket) do
  #   view = params["view"]
  #   animation_class = params["animation-class"]

  #   socket =
  #     assign(socket, %{
  #       previous_view: socket.assigns.current_view,
  #       current_view: view,
  #       animation_class: animation_class
  #     })

  #   # IO.puts("Animation: #{socket.assigns.animation}")

  #   {:noreply, socket}
  # end
end
