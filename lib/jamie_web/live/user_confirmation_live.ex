defmodule JamieWeb.UserConfirmationLive do
  use JamieWeb, :live_view

  alias Jamie.Accounts

  def render(assigns), do: ~H""

  def mount(%{"token" => token}, _session, socket) do
    case Accounts.get_user_by_magic_link_token(token) do
      {:ok, user} ->
        Accounts.delete_magic_link_tokens_for_user(user)
        {:ok, _} = Accounts.confirm_user(user)

        {:ok,
         socket
         |> put_flash(:info, "Account confirmed successfully!")
         |> redirect(to: ~p"/login")}

      :error ->
        {:ok,
         socket
         |> put_flash(:error, "Confirmation link is invalid or it has expired.")
         |> redirect(to: ~p"/login")}
    end
  end
end
