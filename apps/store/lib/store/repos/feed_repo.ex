defmodule Store.FeedRepo do
  @moduledoc false
  use Ecto.Repo, otp_app: :store
  use Paginator
end
