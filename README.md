### "Sleeping Barber Problem" in Elixir

First pass at a solution to [Sleeping Barber Problem](https://en.wikipedia.org/wiki/Sleeping_barber_problem) in Elixir.

# Usage

```elixir
$ brew install elixir
$ iex barber_shop.exs
iex> Shop.open
#=> registering barber: #PID<0.67.0>
iex> Shop.add ["marge", "homer", "maggie", "bart", "lisa"]
#=> homer is sitting down
#=> cutting hair for marge
#=> maggie is sitting down
#=> bart is sitting down
#=> shop is full, lisa is leaving ...
iex> Shop.status?
#=> in chair: "marge"
#=> waiting: ["homer", "maggie", "bart"]
iex> Shop.barber?
#=> barber is currently cutting hair for marge
```

ᕕ( ᐛ )ᕗ

---
Brewed by [Sean Omlor](http://seanomlor.com). [MIT License](/LICENSE).
