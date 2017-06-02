defmodule PhoenixBlog.RoleChecker do
  alias PhoenixBlog.Repo
  alias PhoenixBlog.Role

  def is_admin?(user) do
    (role = Repo.get(Role, user.role_id)) && role.admin
  end
end
