defmodule JamieWeb.HomeLive do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(_params, _session, socket) do
    public_occurences = Occurences.list_public_occurences()

    {:ok, assign(socket, :public_occurences, public_occurences)}
  end
end
