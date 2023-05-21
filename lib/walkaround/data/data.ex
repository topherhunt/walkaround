defmodule Walkaround.Data do
  import ExAws.S3
  require Logger

  # DANGEROUS.
  def __delete_all_objects_on_s3 do
    bucket_name = H.env!("AWS_S3_BUCKET")

    list_objects(bucket_name)
    |> ExAws.stream!()
    |> Enum.each(&delete_object_from_s3(&1, bucket_name))
  end

  defp delete_object_from_s3(%{key: key}, bucket_name) do
    case delete_object(bucket_name, key) |> ExAws.request() do
      {:ok, _} ->
        Logger.info("[#{bucket_name}] Deleted object: #{key}")

      {:error, error} ->
        Logger.error("[#{bucket_name}] Failed to delete object: #{key}. Error: #{inspect(error)}")
    end
  end
end
