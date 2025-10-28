#!/usr/bin/env elixir

Mix.install([]) unless Code.ensure_loaded?(Mix)

# Use the existing app context
Application.ensure_all_started(:jamie)

alias Jamie.Repo

# Truncate the users table
case Repo.query("TRUNCATE TABLE users CASCADE;") do
  {:ok, result} ->
    IO.puts("✅ Successfully truncated users table")
    IO.inspect(result)
  
  {:error, error} ->
    IO.puts("❌ Error truncating users table")
    IO.inspect(error)
end

