defmodule PhoenixBlog.PageView do
  use PhoenixBlog.Web, :view

  def get_link_to_post(post) do
    user_id = to_string(post.user_id)
    id = to_string(post.id)
    "/users/" <> user_id <> "/posts/" <> id <> "/page"
  end
end
