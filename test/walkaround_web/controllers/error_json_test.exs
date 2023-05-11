defmodule WalkaroundWeb.ErrorJSONTest do
  use WalkaroundWeb.ConnCase, async: true

  test "renders 404" do
    assert WalkaroundWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert WalkaroundWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
