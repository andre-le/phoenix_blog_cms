defmodule PhoenixBlog.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :tittle, :string
      add :body, :text
      timestamps()
    end

  end
end
