defmodule WalkaroundWeb.UserControllerTest do
  use WalkaroundWeb.ConnCase
  alias Walkaround.Data
  alias Walkaround.Data.User

  setup do
    # Clear all emails sent by previous tests. Tests CANNOT be async.
    Bamboo.SentEmail.reset()
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      user = Factory.insert_user()
      conn = login(conn, user)

      conn = get(conn, ~p"/account/edit")

      assert_selector(conn, "h1", html: "Account settings")
    end
  end

  describe "#update" do
    test "user can update their name and password", %{conn: conn} do
      user = Factory.insert_user()
      conn = login(conn, user)

      params = %{
        "user" => %{
          "name" => "New name",
          "password" => "password2",
          "password_confirmation" => "password2",
          "current_password" => "password"
        }
      }

      conn = patch(conn, ~p"/account/update", params)

      assert redirected_to(conn) == ~p"/account/edit"
      updated_user = Repo.get!(User, user.id)
      assert updated_user.name == "New name"
      assert Data.password_correct?(updated_user, "password2")
    end

    test "user can update just their name", %{conn: conn} do
      user = Factory.insert_user()
      conn = login(conn, user)

      params = %{"user" => %{"name" => "New name"}}
      conn = patch(conn, ~p"/account/update", params)

      assert redirected_to(conn) == ~p"/account/edit"
      # Name has changed
      assert Repo.get!(User, user.id).name == "New name"
    end

    test "rejects if name is invalid", %{conn: conn} do
      user = Factory.insert_user()
      conn = login(conn, user)

      params = %{"user" => %{"name" => ""}}
      conn = patch(conn, ~p"/account/update", params)

      assert_text(conn, "can't be blank")
      # Name hasn't changed
      assert Repo.get!(User, user.id).name == user.name
    end

    test "rejects if updating password and current_password is incorrect", %{conn: conn} do
      user = Factory.insert_user()
      conn = login(conn, user)

      params = %{
        "user" => %{
          "name" => "New name",
          "password" => "password2",
          "password_confirmation" => "password2",
          "current_password" => "wrong"
        }
      }

      conn = patch(conn, ~p"/account/update", params)

      assert_text(conn, "is incorrect")
      # PW hasn't changed
      assert Repo.get!(User, user.id) |> Data.password_correct?("password")
    end
  end

  describe "#update_email" do
    test "sends you an email confirmation link, but doesn't update email", %{conn: conn} do
      user = Factory.insert_user()
      conn = login(conn, user)

      params = %{"user" => %{"email" => "new_email@example.com"}}
      conn = patch(conn, ~p"/account/update_email", params)

      assert redirected_to(conn) == ~p"/account/edit"
      assert flash_messages(conn) =~ "We just sent a confirmation link"
      # email hasn't changed (yet)
      assert Repo.get!(User, user.id).email == user.email
      assert_email_sent(to: "new_email@example.com", subject: "Please confirm your address")
    end

    test "rejects if that email address is taken", %{conn: conn} do
      user = Factory.insert_user()
      user2 = Factory.insert_user()
      conn = login(conn, user)

      params = %{"user" => %{"email" => user2.email}}
      conn = patch(conn, ~p"/account/update_email", params)

      assert redirected_to(conn) == ~p"/account/edit"
      assert flash_messages(conn) =~ "The email address #{user2.email} is already taken"
    end
  end
end
