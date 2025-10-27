defmodule JamieWeb.MarkdownEditor do
  @moduledoc """
  A simple textarea component for markdown editing.
  (EasyMDE was removed due to stability issues)
  """
  use Phoenix.Component

  attr :field, Phoenix.HTML.FormField, required: true, doc: "The form field"
  attr :label, :string, default: "Description", doc: "The field label"
  attr :rows, :integer, default: 5, doc: "Number of rows for the textarea"
  attr :placeholder, :string, default: "Enter your description using markdown...", doc: "Placeholder text"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def markdown_editor(assigns) do
    ~H"""
    <div class={["fieldset", @class]}>
      <label for={@field.id} class="label">
        <span class="label-text font-semibold">{@label}</span>
        <span class="label-text-alt text-xs text-base-content/60">Supports markdown formatting</span>
      </label>

      <textarea
        id={@field.id}
        name={@field.name}
        rows={@rows}
        placeholder={@placeholder}
        class="textarea textarea-bordered w-full"
      >{Phoenix.HTML.Form.normalize_value("textarea", @field.value)}</textarea>
    </div>
    """
  end
end
