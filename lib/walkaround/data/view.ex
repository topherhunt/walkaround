defmodule Walkaround.Data.View do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Walkaround.Repo
  alias __MODULE__

  schema "views" do
    field(:position, :integer)
    field(:image, Walkaround.Arc.Image.Type)
    field(:image_peek_up, Walkaround.Arc.Image.Type)
    field(:image_peek_forward, Walkaround.Arc.Image.Type)

    # These virtual attrs manage acts_as_list-style ordered scoped lists.
    field(:position_changed, :boolean, virtual: true)
    field(:previous_position, :integer, virtual: true)

    belongs_to(:node, Walkaround.Data.Node)
    # If there's a path forward, this FK indicates which view it goes to.
    belongs_to(:linked_view, Walkaround.Data.View)

    timestamps()
  end

  def changeset(view, attrs) do
    view
    |> cast(attrs, [:node_id, :linked_view_id, :position])
    |> maybe_cast_attachments(attrs)
    |> set_position_changed()
    |> set_previous_position()
    |> set_default_position()
    |> validate_required([:node_id, :position])
  end

  # You can't attach ArcEcto files to a record that hasn't been inserted yet.
  defp maybe_cast_attachments(changeset, attrs) do
    if persisted?(changeset) do
      changeset
    else
      cast_attachments(changeset, attrs, [:image, :image_peek_up, :image_peek_forward])
    end
  end

  defp set_position_changed(changeset) do
    if get_change(changeset, :position) do
      put_change(changeset, :position_changed, true)
    else
      changeset
    end
  end

  defp set_previous_position(changeset) do
    put_change(changeset, :previous_position, changeset.data.position)
  end

  defp set_default_position(changeset) do
    if !get_field(changeset, :position) do
      node_id = get_field(changeset, :node_id)
      max_position = Repo.one(View.filter(node_id: node_id) |> select([v], max(v.position))) || 0
      put_change(changeset, :position, max_position + 1)
    else
      changeset
    end
  end

  defp persisted?(changeset), do: !!changeset.data.id

  #
  # Query builders
  #

  def filter(starting_query \\ __MODULE__, filters) when is_list(filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :node_id, node_id), do: where(query, [t], t.node_id == ^node_id)

  def filter(query, :id_not, id), do: where(query, [t], t.id != ^id)

  def filter(query, :position_gt, pos), do: where(query, [t], t.position > ^pos)

  def filter(query, :position_gte, pos), do: where(query, [t], t.position >= ^pos)
end
