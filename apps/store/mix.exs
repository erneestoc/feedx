defmodule Store.MixProject do
  use Mix.Project

  def project do
    [
      app: :store,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Store, []},
      extra_applications: [:logger, :ecto, :con_cache, :poison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:mariaex, "~> 0.8.2"},
      {:ecto, "~> 2.1"},
      {:con_cache, "~> 0.12.1"},
      {:poison, "~> 3.1"},
      {:faker, "~> 0.10", only: :test}
    ]
  end
end
