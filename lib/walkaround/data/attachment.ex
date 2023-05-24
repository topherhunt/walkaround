defmodule Walkaround.Data.Attachment do
  use Ecto.Schema
  use Arc.Ecto.Schema

  schema "attachments" do
    field(:image, Walkaround.Arc.AttachmentImage.Type)
    timestamps()
  end

  def changeset(attachment, attrs) do
    attachment
    # |> cast(attrs, [:image])
    |> cast_attachments(attrs, [:image])

    # |> validate_required([:image])
  end
end
