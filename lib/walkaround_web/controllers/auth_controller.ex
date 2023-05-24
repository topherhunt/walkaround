defmodule WalkaroundWeb.AuthController do
  require Logger
  use WalkaroundWeb, :controller
  alias Walkaround.Data
  alias Walkaround.Data.User
  alias WalkaroundWeb.AuthPlugs

  def signup(conn, _params) do
    changeset = User.changeset(%User{}, %{}, :owner)
    render(conn, "signup.html", changeset: changeset, page_title: "Sign up")
  end

  def signup_submit(conn, %{"user" => user_params}) do
    case Data.insert_user(user_params, :owner) do
      {:ok, user} ->
        log(:info, "Registered new user #{user.id}.")
        Walkaround.Emails.confirm_address(user, user.email) |> Walkaround.Mailer.send()

        conn
        |> put_flash(
          :info,
          "Thanks for registering! Please check your inbox for a confirmation link."
        )
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        render(conn, "signup.html", changeset: changeset, page_title: "Sign up")
    end
  end

  def login(conn, _params) do
    render(conn, "login.html", page_title: "Log in")
  end

  def login_submit(conn, %{"user" => %{"email" => email, "password" => password}}) do
    # may be nil
    user = User.filter(email: email) |> Repo.one()
    pw_correct = Data.password_correct?(user, password)
    confirmed = user && user.confirmed_at != nil
    account_locked = Data.count_recent_login_tries(email) >= 5

    cond do
      account_locked ->
        log(:info, "Login failed: account is locked.")

        conn
        |> put_flash(
          :error,
          "Your account is locked. Please try again in 15 minutes, or reset your password using the link below."
        )
        |> redirect(to: ~p"/auth/login")

      !pw_correct ->
        log(:info, "Login failed: incorrect email or password.")
        Data.insert_login_try!(email)

        conn
        |> put_flash(:error, "That email or password is incorrect. Please try again.")
        |> redirect(to: ~p"/auth/login")

      !confirmed ->
        log(:info, "Login failed: user #{user.id} account is not confirmed.")

        conn
        |> put_flash(
          :error,
          "You need to confirm your email address before you can log in. Please check your inbox, or use this page to request a new confirmation link."
        )
        |> redirect(to: ~p"/auth/request_email_confirm")

      true ->
        log(:info, "Logged in user #{user.id}.")
        Data.clear_login_tries(email)

        conn
        |> AuthPlugs.login!(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    conn
    |> AuthPlugs.logout!()
    |> redirect(to: ~p"/")
  end

  #
  # Email confirmation
  #

  # This displays the "Re-send confirmation link" page
  def request_email_confirm(conn, _params) do
    title = "Confirm your email address"
    render(conn, "request_email_confirm.html", page_title: title)
  end

  # The user has submitted the "Re-send confirmation link" form
  # NOTE: This allows user enumeration. See https://security.stackexchange.com/q/158075
  def request_email_confirm_submit(conn, %{"user" => %{"email" => email}}) do
    user = User.filter(email: email) |> Repo.one()

    cond do
      user == nil ->
        conn
        |> put_flash(
          :error,
          "The email address '#{email}' doesn't exist in our system. Maybe you signed up using a different address?"
        )
        |> redirect(to: ~p"/auth/request_email_confirm")

      user.confirmed_at != nil ->
        conn
        |> put_flash(
          :error,
          "This address is already confirmed. Log in below."
        )
        |> redirect(to: ~p"/auth/login")

      true ->
        Walkaround.Emails.confirm_address(user, user.email) |> Walkaround.Mailer.send()

        conn
        |> put_flash(
          :info,
          "We've emailed a link to #{user.email}. Please check your inbox."
        )
        |> redirect(to: ~p"/auth/request_email_confirm")
    end
  end

  # This endpoint can be called either to confirm the user's current email, or to change
  # to a new (and newly confirmed) email.
  def confirm_email(conn, %{"token" => token}) do
    case Data.parse_token(token) do
      {:ok, {:confirm_email, user_id, email}} ->
        user = Repo.get!(User, user_id)
        # This can fail in a rare edge case when switching to a just-taken email address.
        Data.update_user!(user, %{email: email, confirmed_at: DateTime.utc_now()}, :admin)
        Data.invalidate_token!(token)

        conn
        |> AuthPlugs.login!(user)
        |> put_flash(:info, "Thanks! Your email address is confirmed.")
        |> redirect(to: ~p"/")

      {:error, _} ->
        conn
        |> put_flash(:error, "That link is no longer valid. Please try again.")
        |> redirect(to: ~p"/auth/request_email_confirm")
    end
  end

  #
  # Password resets
  #

  # Displays the form for requesting a password reset link.
  def request_password_reset(conn, _params) do
    title = "Reset your password"
    render(conn, "request_password_reset.html", page_title: title)
  end

  def request_password_reset_submit(conn, %{"user" => %{"email" => email}}) do
    if user = Repo.one(User.filter(email: email)) do
      Walkaround.Emails.reset_password(user) |> Walkaround.Mailer.send()

      conn
      |> put_flash(
        :info,
        "We've emailed a link to #{user.email}. Please check your inbox."
      )
      |> redirect(to: ~p"/auth/request_password_reset")
    else
      # NOTE: Minor privacy hole. See https://security.stackexchange.com/q/158075
      conn
      |> put_flash(
        :error,
        "The email address '#{email}' doesn't exist in our system. Maybe you signed up using a different address?"
      )
      |> redirect(to: ~p"/auth/request_password_reset")
    end
  end

  # Displays the form for actually resetting your password. (accessed via PW reset link)
  def reset_password(conn, %{"token" => token}) do
    case Data.parse_token(token) do
      {:ok, {:reset_password, _user_id}} ->
        # If the pw reset token is valid, we render the form for the user to set a new pw.
        render(conn, "reset_password.html",
          token: token,
          changeset: User.changeset(%User{}, %{}, :owner),
          page_title: "Reset your password"
        )

      {:error, _} ->
        conn
        |> put_flash(:error, "That link is no longer valid. Please try again.")
        |> redirect(to: ~p"/auth/request_password_reset")
    end
  end

  def reset_password_submit(conn, %{"token" => token, "user" => user_params}) do
    case Data.parse_token(token) do
      {:ok, {:reset_password, user_id}} ->
        user = Repo.get!(User, user_id)

        case Data.update_user(user, user_params, :password_reset) do
          {:ok, _} ->
            Data.clear_login_tries(user.email)
            Data.invalidate_token!(token)

            conn
            |> put_flash(:info, "Password updated. Please log in.")
            |> redirect(to: ~p"/auth/login")

          {:error, changeset} ->
            title = "Reset your password"

            render(conn, "reset_password.html",
              token: token,
              changeset: changeset,
              page_title: title
            )
        end

      {:error, _} ->
        conn
        |> put_flash(:error, "Sorry, something went wrong. Please try again.")
        |> redirect(to: ~p"/auth/request_password_reset")
    end
  end

  #
  # Helpers
  #

  defp log(level, message), do: Logger.log(level, "AuthController: #{message}")
end
