defmodule WalkaroundWeb.KittenControllerTest do
  use WalkaroundWeb.ConnCase

  import Walkaround.AnimalsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all kittens", %{conn: conn} do
      conn = get(conn, ~p"/kittens")
      assert html_response(conn, 200) =~ "Listing Kittens"
    end
  end

  describe "new kitten" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/kittens/new")
      assert html_response(conn, 200) =~ "New Kitten"
    end
  end

  describe "create kitten" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/kittens", kitten: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/kittens/#{id}"

      conn = get(conn, ~p"/kittens/#{id}")
      assert html_response(conn, 200) =~ "Kitten #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/kittens", kitten: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Kitten"
    end
  end

  describe "edit kitten" do
    setup [:create_kitten]

    test "renders form for editing chosen kitten", %{conn: conn, kitten: kitten} do
      conn = get(conn, ~p"/kittens/#{kitten}/edit")
      assert html_response(conn, 200) =~ "Edit Kitten"
    end
  end

  describe "update kitten" do
    setup [:create_kitten]

    test "redirects when data is valid", %{conn: conn, kitten: kitten} do
      conn = put(conn, ~p"/kittens/#{kitten}", kitten: @update_attrs)
      assert redirected_to(conn) == ~p"/kittens/#{kitten}"

      conn = get(conn, ~p"/kittens/#{kitten}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, kitten: kitten} do
      conn = put(conn, ~p"/kittens/#{kitten}", kitten: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Kitten"
    end
  end

  describe "delete kitten" do
    setup [:create_kitten]

    test "deletes chosen kitten", %{conn: conn, kitten: kitten} do
      conn = delete(conn, ~p"/kittens/#{kitten}")
      assert redirected_to(conn) == ~p"/kittens"

      assert_error_sent 404, fn ->
        get(conn, ~p"/kittens/#{kitten}")
      end
    end
  end

  defp create_kitten(_) do
    kitten = kitten_fixture()
    %{kitten: kitten}
  end
end
