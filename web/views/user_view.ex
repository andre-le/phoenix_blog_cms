defmodule PhoenixBlog.UserView do
  use PhoenixBlog.Web, :view

  def roles_for_select(roles) do
    roles
    |> Enum.map(fn role -> ["#{role.name}": role.id] end)
    |> List.flatten
  end

end
