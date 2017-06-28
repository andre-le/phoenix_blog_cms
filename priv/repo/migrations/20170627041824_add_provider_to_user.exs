defmodule PhoenixBlog.Repo.Migrations.AddProviderToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :uid, :string
      add :provider, :string
    end
  end
end
