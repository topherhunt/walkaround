defmodule Walkaround.AnimalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Walkaround.Animals` context.
  """

  @doc """
  Generate a kitten.
  """
  def kitten_fixture(attrs \\ %{}) do
    {:ok, kitten} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Walkaround.Animals.create_kitten()

    kitten
  end
end
