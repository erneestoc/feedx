use Mix.Config

config :web, Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :web, Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{web/views/.*(ex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
