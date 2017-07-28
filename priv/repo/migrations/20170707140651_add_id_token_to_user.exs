defmodule PhoenixBlog.Repo.Migrations.AddIdTokenToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :refresh_token, :string, size: 1000
    end
  end
end
