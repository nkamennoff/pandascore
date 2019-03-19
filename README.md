# Panda

Technical test for panda score interview process.
This short test program allow to retrieve upcoming matches and to get odds for match.

## Usage

To avoid hardcoding Panda score API token, I use environment variable (TOKEN) thus please set it or launch the iex
interpreter using:
```
TOKEN=<your token> iex -S mix

```

### Upcoming matches

Once in the iex interpreter use upcoming_matches from the Panda module:
```elixir
Panda.upcoming_matches
```

### Odds for match

You can retrieve odds computed for a given match using the odds_for_match from the Panda module:
```elixir
Panda.odds_for_match(match_id)
```

Odds are computed using bayesian inference and cached so that the second call won't use any API requests.