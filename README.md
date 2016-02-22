### "Sleeping Barber Problem" in Elixir

Tinkering with solution to [Sleeping Barber Problem](https://en.wikipedia.org/wiki/Sleeping_barber_problem) in Elixir.

# Usage

```elixir
$ brew install elixir
$ iex barber_shop.exs
iex> Shop.open
#PID<0.63.0>
iex> Shop.add ["marge", "homer", "maggie", "bart", "lisa"]
# barber chair is empty, marge is waking up the barber
# barber is cutting hair for marge
# homer is sitting down
# maggie is sitting down
# bart is sitting down
# shop is full, lisa is leaving
# [:ok, :ok, :ok, :ok, :ok]
iex>
# barber is done cutting hair for marge
# homer is next in line
# barber is cutting hair for homer
iex> Shop.status
# in chair: "homer"
# waiting: ["maggie", "bart"]
iex>
# barber is done cutting hair for homer
# maggie is next in line
# barber is cutting hair for maggie
# barber is done cutting hair for maggie
# bart is next in line
# barber is cutting hair for bart
# barber is done cutting hair for bart
# no one else is waiting
```

ᕕ( ᐛ )ᕗ

---
Brewed by [Sean Omlor](http://seanomlor.com). [MIT License](/LICENSE).
