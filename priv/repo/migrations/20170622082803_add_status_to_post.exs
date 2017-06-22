defmodule PhoenixBlog.Repo.Migrations.AddStatusToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :status, :string
      remove :publish, :string
      remove :draft, :boolean
    end
  end
end
