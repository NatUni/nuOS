import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sparkplug, Sparkplug.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "j42O3LH1YTP6NMmFExwkANBuQ0CjYU3DOvGBPOajh+lk+M/NxP8QmraZd3zPqy5V",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :crankshaft, Crankshaft.Mailer,
  adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
