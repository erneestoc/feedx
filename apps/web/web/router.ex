defmodule Web.Router do
  use Web.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", Web do
    pipe_through :api

    get "/feed", FeedController, :full_index
    get "/feed/:tenant_id", FeedController, :tenant_index

    get "/feed/:tenant_id/events/:event_id/likes", EventController, :index
    get "/feed/:tenant_id/events/:event_id/like", EventController, :like
    get "/feed/:tenant_id/events/:event_id/unlike", EventController, :unlike

    get "/feed/:tenant_id/events/:event_id/comments", CommentController, :index
    post "/feed/:tenant_id/events/:event_id/comments", CommentController, :create
    put "/feed/:tenant_id/events/:event_id/comments/:comment_id", CommentController, :update
    patch "/feed/:tenant_id/events/:event_id/comments/:comment_id", CommentController, :update
    delete "/feed/:tenant_id/events/:event_id/comments/:comment_id", CommentController, :delete
  end

end
