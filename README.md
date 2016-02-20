### "Sleeping Barber Problem" in Elixir

First pass at a solution to [Sleeping Barber Problem](https://en.wikipedia.org/wiki/Sleeping_barber_problem) in Elixir.

# Usage

```elixir
$ brew install elixir
$ iex barber_shop.exs
iex> Shop.open
#=> registering barber: #PID<0.67.0>
iex> Shop.add ["marge", "homer", "maggie", "bart", "lisa"]
#=> barber chair is empty, marge is waking up the barber
#=> homer is sitting down
#=> cutting hair for marge
#=> maggie is sitting down
#=> bart is sitting down
#=> shop is full, lisa is leaving
iex>
#=> barber is finished cutting hair for marge
#=> homer is next in line
#=> cutting hair for homer
#=> barber is finished cutting hair for homer
#=> maggie is next in line
#=> cutting hair for maggie
#=> barber is finished cutting hair for maggie
#=> bart is next in line
#=> cutting hair for bart
#=> barber is finished cutting hair for bart
#=> no one else is waiting
#=> yawn. not much to do around here...
iex> Shop.status?
#=> in chair: nil
#=> waiting: []
iex> Shop.barber?
#=> barber fell asleep
```

ᕕ( ᐛ )ᕗ

---
Brewed by [Sean Omlor](http://seanomlor.com). [MIT License](/LICENSE).
