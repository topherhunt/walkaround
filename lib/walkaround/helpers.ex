defmodule Walkaround.Helpers do
  def env, do: Application.get_env(:walkaround, :mix_env)
end
