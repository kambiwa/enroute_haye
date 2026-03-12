defmodule EnrouteHayeWeb.PageController do
  use EnrouteHayeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
