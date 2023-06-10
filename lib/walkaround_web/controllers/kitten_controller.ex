defmodule WalkaroundWeb.KittenController do
  use WalkaroundWeb, :controller

  alias Walkaround.Animals
  alias Walkaround.Animals.Kitten

  def index(conn, _params) do
    kittens = Animals.list_kittens()
    render(conn, :index, kittens: kittens)
  end

  def new(conn, _params) do
    changeset = Animals.change_kitten(%Kitten{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"kitten" => kitten_params}) do
    case Animals.create_kitten(kitten_params) do
      {:ok, kitten} ->
        conn
        |> put_flash(:info, "Kitten created successfully.")
        |> redirect(to: ~p"/kittens/#{kitten}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    kitten = Animals.get_kitten!(id)
    render(conn, :show, kitten: kitten)
  end

  def edit(conn, %{"id" => id}) do
    kitten = Animals.get_kitten!(id)
    changeset = Animals.change_kitten(kitten)
    render(conn, :edit, kitten: kitten, changeset: changeset)
  end

  def update(conn, %{"id" => id, "kitten" => kitten_params}) do
    kitten = Animals.get_kitten!(id)

    case Animals.update_kitten(kitten, kitten_params) do
      {:ok, kitten} ->
        conn
        |> put_flash(:info, "Kitten updated successfully.")
        |> redirect(to: ~p"/kittens/#{kitten}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, kitten: kitten, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    kitten = Animals.get_kitten!(id)
    {:ok, _kitten} = Animals.delete_kitten(kitten)

    conn
    |> put_flash(:info, "Kitten deleted successfully.")
    |> redirect(to: ~p"/kittens")
  end
end
