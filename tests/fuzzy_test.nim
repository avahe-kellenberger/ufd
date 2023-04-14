import nimtest
import fuzzy

describe "Fuzzy searcher tests":

  it "Checks score comparisons":
    block:
      let scoreA = score("Marc", "Marcel#3414")
      let scoreB = score("Marc", "Maurice")
      let scoreC = score("Marc", "Marchesi#9331")
      assert scoreA > scoreB
      assert scoreC > scoreB

    block:
      assert(score("S", "cvcx") < 0)
      assert(score("S", "scheme god#2313") > 0)
      assert(score("K", "KC") > 0)
      assert(score("s", "space") > 0)
      assert(score("Hual#1299 ", "Thur_MaliGnY#1112") < 0)

    block:
        assert(score("gnw", "mr_game_and_watch") > 0)

    block:
      let scoreA = score("sout", "lexjusto#4214")
      let scoreB = score("sout", "Southclaws#4153")
      assert(scoreA < scoreB)

  it "Properly sorts searches on arrays of strings":
    let arr = [ "tests", "test", "Testosterone", "atesta", "bob" ]
    let sorted = sortByScore("Te", arr)
    let expected = @[ "Testosterone", "test", "tests", "atesta" ]
    assertEquals(sorted, expected)

