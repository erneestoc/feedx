defmodule Web.Router do
  use Web.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1" do
    pipe_through :api

    get "/feed", FeedController, :full_index
    get "/feed/:tenant_id", FeedController, :tentant_index

    get "/feed/:tenant_id/events/:event_id", EventController, :show
    get "/feed/:tenant_id/events/:event_id/like", EventController, :like
    get "/feed/:tenant_id/events/:event_id/unlike", EventController, :unlike

    get "/feed/:tenant_id/events/:event_id/comments", CommentController, :index
    post "/feed/:tenant_id/events/:event_id/comments", CommentController, :create
    put "/feed/:tenant_id/events/:event_id/comments/:comment_id", CommentController, :update
    patch "/feed/:tenant_id/events/:event_id/comments/:comment_id", CommentController, :update
    delete "/feed/:tenant_id/events/:event_id/comments/:comment_id", CommentController, :delete
  end

end
