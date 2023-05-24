defmodule WalkaroundWeb.HelperHTML do
  import Phoenix.HTML.Tag

  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, error, class: "help-block")
    end)
  end

  def required do
    Phoenix.HTML.raw(
      " <span class='text-danger u-tooltip-target'>*<div class='u-tooltip'>Required</div></span>"
    )
  end
end
