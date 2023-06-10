defmodule Walkaround.Data.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Walkaround.Data

  schema "users" do
    field(:slug, :string)
    field(:name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:current_password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :utc_datetime)
    field(:last_visit_date, :date)

    has_many(:places, Walkaround.Data.Place)

    timestamps()
  end

  def changeset(struct, params, :admin) do
    struct
    |> cast(params, [:name, :email, :password, :confirmed_at, :last_visit_date])
    |> validate_required([:name, :email])
    |> validate_length(:password, min: 8, max: 50)
    |> unique_constraint(:email)
    |> downcase_field(:email)
    |> require_password()
    |> hash_password_if_present()
    |> Walkaround.Repo.generate_slug()
  end

  def changeset(struct, params, :owner) do
    struct
    |> cast(params, [:name, :email, :password, :password_confirmation, :current_password])
    |> disallow_field_change(:email)
    |> validate_password_confirmation()
    |> validate_current_password()
    # now do the standard validations & data prep steps
    |> changeset(%{}, :admin)
  end

  # We need a special context for pw resets because current_password isn't required there
  def changeset(struct, params, :password_reset) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_password_confirmation()
    # now do the standard validations & data prep steps
    |> changeset(%{}, :admin)
  end

  #
  # Validation helpers
  #

  defp hash_password_if_present(changeset) do
    if password = get_change(changeset, :password) do
      changeset |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
    else
      changeset
    end
  end

  defp require_password(changeset) do
    if !get_field(changeset, :password_hash) && !get_change(changeset, :password) do
      add_error(changeset, :password, "can't be blank")
    else
      changeset
    end
  end

  # NOTE: There's also https://hexdocs.pm/ecto/Ecto.Changeset.html#validate_confirmation/3
  defp validate_password_confirmation(changeset) do
    pw = get_change(changeset, :password)
    pw_confirmation = get_change(changeset, :password_confirmation)

    if pw != nil && pw != pw_confirmation do
      add_error(changeset, :password_confirmation, "doesn't match password")
    else
      changeset
    end
  end

  # TODO: See RTL's more up-to-date implementation of validate_password_change()
  defp validate_current_password(changeset) do
    user = changeset.data
    is_user_persisted = user.id != nil
    is_changing_pw = get_change(changeset, :password) != nil

    if is_user_persisted && is_changing_pw do
      current_pw = get_change(changeset, :current_password)
      current_pw_correct = Data.password_correct?(user, current_pw)

      if !current_pw_correct do
        add_error(changeset, :current_password, "errors", "is incorrect")
      else
        changeset
      end
    else
      changeset
    end
  end

  defp disallow_field_change(changeset, field) do
    # Users can't directly change their email address after registering. UserController#update has logic for updating email via confirmation link.
    if get_field(changeset, :id) && get_change(changeset, field) do
      add_error(changeset, field, "can't be changed")
    else
      changeset
    end
  end

  defp downcase_field(changeset, field) do
    if value = get_change(changeset, field) do
      changeset |> put_change(field, String.downcase(value))
    else
      changeset
    end
  end

  #
  # Filters
  #

  def filter(orig_query \\ __MODULE__, filters) when is_list(filters) do
    Enum.reduce(filters, orig_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  # Don't do Repo.get_by(User, email: email) because that's case-sensitive!
  def filter(query, :email, e), do: where(query, [t], t.email == ^String.downcase(e))
end
