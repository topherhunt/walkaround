defmodule WalkaroundWeb.KittenHTML do
  use WalkaroundWeb, :html

  embed_templates("kitten_html/*")

  @doc """
  Renders a kitten form.
  """
  attr(:changeset, Ecto.Changeset, required: true)
  attr(:action, :string, required: true)

  def kitten_form(assigns)
end
