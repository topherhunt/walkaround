defmodule Walkaround.Data do
  import Ecto.Query
  import ExAws.S3
  require Logger
  alias Walkaround.Repo
  alias Walkaround.Data.{User, Nonce, LoginTry, Place, Node, View}

  #
  # Users
  #

  def insert_user!(a \\ %User{}, b, c), do: insert_user(a, b, c) |> Repo.unwrap!()

  def insert_user(%User{} = struct \\ %User{}, params, scope) do
    struct |> User.changeset(params, scope) |> Repo.insert()
  end

  def update_user!(a, b, c), do: update_user(a, b, c) |> Repo.unwrap!()

  def update_user(%User{} = struct, params, scope) do
    struct |> User.changeset(params, scope) |> Repo.update()
  end

  def delete_user!(user), do: Repo.delete!(user)

  def password_correct?(user_or_nil, password) do
    case Argon2.check_pass(user_or_nil, password) do
      {:ok, _user} -> true
      {:error, _msg} -> false
    end
  end

  #
  # Tokens (part of the auth system)
  #

  # Phoenix.Token gives us signed, salted, reversible, expirable tokens for free.
  # To protect from replay attacks, we embed a nonce id in each (otherwise stateless)
  # token. The nonce is validated at parsing time. Be sure to explicitly invalidate
  # the token when it's no longer needed!
  #
  # Usage:
  #   # Generate a single-use token:
  #   token = Data.new_token({:reset_password, user_id})
  #   # Later, parse and validate the token:
  #   {:ok, {:reset_password, user_id}} = Data.parse_token(token)
  #   # IMPORTANT: Destroy the token as soon as you no longer need it.
  #   Data.invalidate_token!(token)

  @endpoint WalkaroundWeb.Endpoint
  @salt "XAnZSi88BVsMtchJVa9"
  @one_day 86400

  def create_token!(data) do
    nonce = insert_nonce!()
    wrapped_data = %{data: data, nonce_id: nonce.id}
    Phoenix.Token.sign(@endpoint, @salt, wrapped_data)
  end

  def parse_token(token) do
    case Phoenix.Token.verify(@endpoint, @salt, token, max_age: @one_day) do
      {:ok, map} ->
        case valid_nonce?(map.nonce_id) do
          true -> {:ok, map.data}
          false -> {:error, "invalid nonce"}
        end

      {:error, msg} ->
        {:error, msg}
    end
  end

  def invalidate_token!(token) do
    {:ok, map} = Phoenix.Token.verify(@endpoint, @salt, token, max_age: :infinity)
    delete_nonce!(map.nonce_id)
    :ok
  end

  #
  # Nonces (part of the auth system)
  #

  def insert_nonce! do
    Nonce.admin_changeset(%Nonce{}, %{}) |> Repo.insert!()
  end

  def valid_nonce?(id) do
    Repo.get(Nonce, id) != nil
  end

  def delete_nonce!(id) do
    Repo.get!(Nonce, id) |> Repo.delete!()
  end

  #
  # Login tries (part of the auth system)
  #

  def insert_login_try!(email) do
    LoginTry.admin_changeset(%LoginTry{}, %{email: email}) |> Repo.insert!()
  end

  def count_recent_login_tries(email) do
    email = String.downcase(email)
    time = Timex.now() |> Timex.shift(minutes: -15)
    LoginTry |> where([t], t.email == ^email and t.inserted_at >= ^time) |> Repo.count()
  end

  def clear_login_tries(email) do
    email = String.downcase(email)
    LoginTry |> where([t], t.email == ^email) |> Repo.delete_all()
  end

  #
  # Places
  #

  def insert_place!(attrs) do
    %Place{}
    |> Place.changeset(attrs)
    |> Repo.insert!()
  end

  def update_place(place, attrs) do
    place
    |> Place.changeset(attrs)
    |> Repo.update()
  end

  def delete_place!(place) do
    Repo.delete!(place)
  end

  #
  # Nodes
  #

  def insert_node!(attrs) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert!()
  end

  def update_node!(node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update!()
  end

  def delete_node!(node) do
    Repo.delete!(node)
  end

  #
  # Views
  #

  # NB: Admin privileges. Don't blindly pass in user params.
  def insert_view!(attrs) do
    %View{}
    |> View.changeset(attrs)
    |> Repo.insert!()
    |> fix_positions()
  end

  def update_view!(view, attrs) do
    view
    |> View.changeset(attrs)
    |> Repo.update!()
    |> fix_positions()
  end

  def delete_view!(view) do
    Repo.delete!(view)

    # Decrement position of all views after it to maintain ordering
    View.filter(node_id: view.node_id, id_not: view.id, position_gt: view.position)
    |> Repo.update_all(dec: [position: 1])

    :ok
  end

  # Example scenarios (assuming 8 views):
  # - move from pos 3 to pos 6
  #   - remove from pos 3, so 4+ shift by -1
  #   - add to pos 6, so 6+ shift by +1
  # - move from pos 6 to pos 3
  #   - remove from pos 6, so 7+ shift by -1
  #   - add to pos 3, so 3+ shift by +1
  # - insert at pos 9 (last, this is default behavior)
  #   - nothing to decrement because this wasn't removed from the list
  #   - add to pos 9, so 9+ shift by +1 (ie. this is a no-op)
  # - insert at pos 2
  #   - nothing to decrement because this wasn't removed from the list
  #   - add to pos 2, so 2+ shift by +1
  defp fix_positions(view) do
    if view.position_changed do
      # "Remove" this view from the position sequence by shifting all later ones DOWN
      if view.previous_position != nil do
        View.filter(node_id: view.node_id, id_not: view.id, position_gt: view.previous_position)
        |> Repo.update_all(dec: [position: 1])
      end

      # Then "add" this view back in at its new location by shifting all same-and-later ones UP
      if true do
        View.filter(node_id: view.node_id, id_not: view.id, position_gte: view.position)
        |> Repo.update_all(inc: [position: 1])
      end
    end
  end

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
