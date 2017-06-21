defmodule PhoenixBlog.Repo.Migrations.AddPublishToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :publish, :boolean
    end
  end
end
