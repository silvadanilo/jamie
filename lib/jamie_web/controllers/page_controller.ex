defmodule JamieWeb.PageController do
  use JamieWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
