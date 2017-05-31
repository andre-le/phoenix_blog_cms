defmodule PhoenixBlog.PageController do
  use PhoenixBlog.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
