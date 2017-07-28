defmodule PhoenixBlog.User do
  use PhoenixBlog.Web, :model
  use Rummage.Ecto
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  import Joken

  schema "users" do
    belongs_to :role, PhoenixBlog.Role
    has_many :posts, PhoenixBlog.Post
    field :username, :string
    field :email, :string
    field :password_digest, :string
    field :uid, :string
    field :provider, :string
    field :refresh_token, :string

    timestamps()

    # Virtual Fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation, :role_id, :uid, :provider, :refresh_token])
    |> validate_required([:username, :email, :password, :password_confirmation, :role_id])
    |> hash_password
    |> get_provider
  end

  #apply to user log in with WeFit
  defp get_provider(changeset) do
      changeset
      |> put_change(:provider, "WeFit")
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_digest, hashpwsalt(password))
    else
      changeset
    end
  end

  def change_refresh_token(changeset, id) do
    changeset
    |> put_change(:refresh_token, id)
  end

  #Call the refres token API, return the new id_token and refresh_token
  def refresh_id_token(refresh_token) do
    request = HTTPotion.post "https://securetoken.googleapis.com/v1/token?key=AIzaSyDAWqDfXKZkM-hBphL5Y58cnPhOVI4c7dg",
    [body: "grant_type=refresh_token&refresh_token=" <> refresh_token,
    headers: ["Content-Type": "application/x-www-form-urlencoded"]]
    data = Poison.decode!(request.body)
    tokens = [data["id_token"], data["refresh_token"]]
    tokens
  end

  def decoded(token) do
    #["Bearer " <> token] = get_req_header(conn, "authorization")
    kid =
      try do
        token
        |> JOSE.JWS.peek_protected()
        |> JOSE.decode()
        |> Map.get("kid")
      catch
        _, _ ->
          nil
      end
    {:ok, {{_, 200, _}, _, body}} = :httpc.request(:get, {'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com', []}, [autoredirect: true], [])
    firebase_keys = JOSE.JWK.from_firebase(IO.iodata_to_binary(body))
    case Map.get(firebase_keys, kid) do
      jwk=%JOSE.JWK{} ->
        verified = JOSE.JWT.verify_strict(jwk, ["RS256"], token)
      _ ->
        nil
        # handle invalid token or kid
    end
  end

end
