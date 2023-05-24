defmodule Walkaround.Emails do
  use Bamboo.Phoenix, view: WalkaroundWeb.EmailsView
  import Bamboo.Email
  alias WalkaroundWeb.Router.Helpers, as: Routes
  alias Walkaround.Data
  alias Walkaround.Data.User
  require Logger

  @endpoint WalkaroundWeb.Endpoint

  def confirm_address(%User{} = user, email) do
    token = Data.create_token!({:confirm_email, user.id, email})
    url = Routes.auth_url(@endpoint, :confirm_email, token: token)
    if Mix.env() == :dev, do: Logger.info("Email confirmation link sent to #{email}: #{url}")

    standard_email()
    |> to(email)
    |> subject("Walkaround: Please confirm your address")
    |> render("confirm_address.html", url: url)
  end

  def reset_password(%User{} = user) do
    token = Data.create_token!({:reset_password, user.id})
    url = Routes.auth_url(@endpoint, :reset_password, token: token)
    if Mix.env() == :dev, do: Logger.info("PW reset link sent to #{user.email}: #{url}")

    standard_email()
    |> to(user.email)
    |> subject("Walkaround: Use this link to reset your password")
    |> render("reset_password.html", url: url)
  end

  #
  # Internal
  #

  defp standard_email do
    new_email()
    |> from({"Walkaround App", "noreply@walkaround.com"})
    |> put_html_layout({WalkaroundWeb.LayoutView, "email.html"})
  end
end
