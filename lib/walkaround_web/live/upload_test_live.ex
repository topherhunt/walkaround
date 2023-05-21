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

  # This callback is required even if it's a no-op.
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

  # Detect form submit, and process / persist each uploaded file (or at least, just the RED image)
  def handle_event("submit-form", _params, socket) do
    IO.inspect(socket.assigns.uploads, label: "uploads")

    uploaded_files =
      consume_uploaded_entries(socket, :image_red, fn %{path: path}, entry ->
        IO.inspect(path, label: "path")
        IO.inspect(entry, label: "file entry")
        dest = Path.join([:code.priv_dir(:walkaround), "static", "uploads", entry.client_name])
        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        # {:ok, ~p"/uploads/#{Path.basename(dest)}"} |> IO.inspect()
        :ok
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end
end
