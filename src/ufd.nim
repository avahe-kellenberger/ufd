import std/[json, os, strutils, options, sequtils, uri]
import jester
import characters, fuzzy

type
  Hitbox = object
    name: Option[string]
    url: string
  Move = object
    hitboxes: seq[Hitbox]
    move_name: string
    startup: Option[string]
    total_frames: Option[string]
    landing_lag: Option[string]
    notes: Option[string]
    base_damage: Option[string]
    shield_lag: Option[string]
    shield_stun: Option[string]
    which_hitbox: Option[string]
    advantage: Option[string]
    active_frames: Option[string]
    hops_autocancel:Option[string]
    hops_actionable:Option[string]
    endlag: Option[string]

  Character = object
    name: string
    moves: Table[string, Move]

proc newCharacter(name: string): Character =
  return Character(name: name, moves: initTable[string, Move]())

var characterCache = initTable[string, Character]()

proc populateCache() =
  for file in walkFiles("./data/*.json"):
    let json = parseFile(file)
    let name = json["name"].str.toLower().replace(" ", "_").replace(".", "")
    var character = newCharacter(name)

    for moveSection in json["move_sections"].elems:
      for moveJson in moveSection["moves"]:
        let moveName = moveJson["move_name"].str
        character.moves[moveName] = moveJson.to(Move)
    characterCache[name] = character

echo "Populating cache..."
populateCache()
echo "Cache built successfully."

proc findCharacter(characterName: string): Option[Character] =
  let searchedNames = sortByScore(characterName.replace(" ", ""), characterList)
  if searchedNames.len > 0 and characterCache.hasKey(searchedNames[0]):
    return some(characterCache[searchedNames[0]])

proc findMove(character: Character, moveName: string): Option[Move] =
  let movesList = character.moves.keys.toSeq()
  let searchedMoves = sortByScore(moveName, movesList)
  if searchedMoves.len > 0:
    return some(character.moves[searchedMoves[0]])

routes:
  get "/characters":
    resp %characterList

  get "/characters/@character/@move":
    let characterQuery = decodeUrl(@"character")
    let characterOpt = findCharacter(characterQuery)
    if characterOpt.isNone:
      resp %"No character found with that name"

    let character = characterOpt.get()
    let moveQuery = decodeUrl(@"move")
    let moveOpt = findMove(character, moveQuery)
    if moveOpt.isNone:
      resp %("Move \"" & @"move" & "\" for character \"" & character.name & "\" not found.")
    else:
      let response = %* {"character": character.name, "move": moveOpt.get()}
      resp response

