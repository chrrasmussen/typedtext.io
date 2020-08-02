defmodule TypedtextWeb.PageController do
  use TypedtextWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
