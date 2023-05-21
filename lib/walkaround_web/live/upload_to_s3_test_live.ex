defmodule WalkaroundWeb.UploadToS3TestLive do
  use WalkaroundWeb, :live_view
  alias Walkaround.Repo
  alias Walkaround.Data.Attachment

  def mount(_params, _session, socket) do
    socket =
      socket
      # |> assign(:uploaded_files, [])
      |> assign(:attachments, Repo.all(Attachment))
      |> allow_upload(:image, accept: ~w(.jpg .jpeg), auto_upload: true)

    {:ok, socket}
  end

  # This callback is required even if it's a no-op.
  def handle_event("validate-image-upload", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  # Detect form submit, and process / persist each uploaded file (or at least, just the RED image)
  def handle_event("submit-form", _params, socket) do
    IO.inspect(socket.assigns.uploads, label: "uploads")

    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      # Convert the %Phoenix.LiveView.UploadEntry{} to an ArcEcto-compatible %Plug.Upload{}
      upload = %Plug.Upload{
        content_type: entry.client_type,
        filename: entry.client_name,
        path: path
      }

      attachment = %Attachment{} |> Attachment.changeset(%{}) |> Repo.insert!()
      attachment |> Attachment.changeset(%{image: upload}) |> Repo.update!()
      {:ok, nil}
    end)

    # socket = update(socket, :uploaded_files, &(&1 ++ uploaded_files))
    socket = assign(socket, :attachments, Repo.all(Attachment))

    {:noreply, socket}
  end
end
