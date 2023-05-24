defmodule WalkaroundWeb.UserController do
  use WalkaroundWeb, :controller
  alias Walkaround.Data
  alias Walkaround.Data.User

  plug(:must_be_logged_in)

  def edit(conn, _params) do
    changeset = User.changeset(conn.assigns.current_user, %{}, :owner)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Data.update_user(user, user_params, :owner) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Your changes were saved.")
        |> redirect(to: ~p"/account/edit")

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def update_email(conn, %{"user" => %{"email" => email}}) do
    if Repo.get_by(User, email: email) == nil do
      user = conn.assigns.current_user
      Walkaround.Emails.confirm_address(user, email) |> Walkaround.Mailer.send()

      conn
      |> put_flash(
        :info,
        "We just sent a confirmation link to #{email}. Please check your inbox."
      )
      |> redirect(to: ~p"/account/edit")
    else
      conn
      |> put_flash(
        :error,
        "The email address '#{email}' is already taken. Please try again."
      )
      |> redirect(to: ~p"/account/edit")
    end
  end
end
