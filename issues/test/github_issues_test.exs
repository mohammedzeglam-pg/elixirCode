defmodule GithubIssuesTest do
  use ExUnit.Case
  doctest Issues
  import Issues.GithubIssues, only: [issues_url: 2]

  test "generate the correct github repo url" do
    uri = issues_url("elixir-lang", "elixir")
    assert uri == "https://api.github.com/repos/elixir-lang/elixir/issues"
  end
end
