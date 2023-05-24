defmodule Walkaround.Arc.Image do
  @moduledoc """
  Uploader for view images.
  """

  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:fullsize, :thumb, :original]

  # All uploaded files should be readable
  @acl :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:fullsize, _) do
    {:ffmpeg, fn input, output -> "-i #{input} -vf scale=1600:1200 -f webp #{output}" end, :webp}
  end

  def transform(:thumb, _) do
    {:ffmpeg, fn input, output -> "-i #{input} -vf scale=120:90 -f webp #{output}" end, :webp}
  end

  # Override the storage directory:
  # WARNING: You cannot use `scope.id` if attaching to a record being inserted. You must first
  # insert the record, then attach the file in a separate changeset.
  def storage_dir(version, {_file, scope}) do
    env = Walkaround.Helpers.env()
    "uploads/#{env}/views/#{scope.id}/#{version}"
  end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
