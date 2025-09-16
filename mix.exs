defmodule RendevousHashVisual.MixProject do
  use Mix.Project

  def project do
    [
      app: :rendevous_hash_visual,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],

      # Documentation
      name: "Rendevous Hash Visual",
      description: "Interactive visualization for Rendevous Hashing",
      source_url: "https://github.com/chgeuer/rendevous_hash_visual",
      homepage_url: "https://github.com/chgeuer/rendevous_hash_visual",
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {RendevousHashVisual.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:usage_rules, "~> 0.1", only: [:dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:phoenix, "~> 1.8.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:reactive_struct, github: "chgeuer/reactive_struct", branch: "main"},
      {:rendevous_hash_topology, github: "chgeuer/rendevous_hash_topology", branch: "main"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind rendevous_hash_visual", "esbuild rendevous_hash_visual"],
      "assets.deploy": [
        "tailwind rendevous_hash_visual --minify",
        "esbuild rendevous_hash_visual --minify",
        "phx.digest"
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  defp docs do
    [
      main: "RendevousHashVisual",
      # logo: "assets/static/images/logo.png",
      extras: [
        "README.md": [title: "Overview"],
        "CHANGELOG.md": [title: "Changelog"]
      ],
      groups_for_modules: [
        "Web Interface": [
          RendevousHashVisualWeb.InteractiveSvgLive
        ],
        "Core Logic": [
          RendevousHashVisual.InteractiveState,
          ReactiveStruct,
          SvgAnimator,
          Animate
        ]
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      markdown_processor: ExDoc.Markdown.Earmark,
      source_ref: "main",
      formatters: ["html", "epub"]
    ]
  end
end
