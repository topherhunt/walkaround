defmodule Walkaround.AnimalsTest do
  use Walkaround.DataCase

  alias Walkaround.Animals

  describe "kittens" do
    alias Walkaround.Animals.Kitten

    import Walkaround.AnimalsFixtures

    @invalid_attrs %{name: nil}

    test "list_kittens/0 returns all kittens" do
      kitten = kitten_fixture()
      assert Animals.list_kittens() == [kitten]
    end

    test "get_kitten!/1 returns the kitten with given id" do
      kitten = kitten_fixture()
      assert Animals.get_kitten!(kitten.id) == kitten
    end

    test "create_kitten/1 with valid data creates a kitten" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Kitten{} = kitten} = Animals.create_kitten(valid_attrs)
      assert kitten.name == "some name"
    end

    test "create_kitten/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Animals.create_kitten(@invalid_attrs)
    end

    test "update_kitten/2 with valid data updates the kitten" do
      kitten = kitten_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Kitten{} = kitten} = Animals.update_kitten(kitten, update_attrs)
      assert kitten.name == "some updated name"
    end

    test "update_kitten/2 with invalid data returns error changeset" do
      kitten = kitten_fixture()
      assert {:error, %Ecto.Changeset{}} = Animals.update_kitten(kitten, @invalid_attrs)
      assert kitten == Animals.get_kitten!(kitten.id)
    end

    test "delete_kitten/1 deletes the kitten" do
      kitten = kitten_fixture()
      assert {:ok, %Kitten{}} = Animals.delete_kitten(kitten)
      assert_raise Ecto.NoResultsError, fn -> Animals.get_kitten!(kitten.id) end
    end

    test "change_kitten/1 returns a kitten changeset" do
      kitten = kitten_fixture()
      assert %Ecto.Changeset{} = Animals.change_kitten(kitten)
    end
  end
end
