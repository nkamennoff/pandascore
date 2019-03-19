use Mix.Config

config :logger, :console,
       format: "$time [$level] $levelpad$message\n",
       level: :info