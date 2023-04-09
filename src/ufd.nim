import std/json
import jester
import characters

routes:
  get "/characters":
    resp %characterList

