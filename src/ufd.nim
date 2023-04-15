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

  Stats = object
    weight: string
    gravity: string
    walk_speed: string
    run_speed: string
    initial_dash: string
    air_speed: string
    total_air_acceleration: string
    sh_fh_shff_fhff_frames: string
    fall_speed_fast_fall_speed: string
    oos_options: seq[string]
    shield_grab: string
    shield_drop: string
    jump_squat: string

  MiscData = object
    stats: Stats
    moves: seq[Move]
    html_id: string

  MoveSection = object
    section_name: string
    html_id: string
    moves: seq[Move]

  CharacterJson = object
    ufd_url: string
    name: string
    move_sections: seq[MoveSection]
    misc_data: MiscData

  Character = object
    name: string
    namePretty: string
    moves: Table[string, Move]

proc newCharacter(name, namePretty: string): Character =
  return Character(name: name, namePretty: namePretty, moves: initTable[string, Move]())

var characterLookup = initTable[string, Character]()

proc populateCache() =
  for file in walkFiles("./data/*.json"):
    let json = parseFile(file)
    let characterName = splitFile(file).name
    let characterJson = json.to(CharacterJson)
    var character = newCharacter(characterName, characterJson.name)
    for moveSection in characterJson.move_sections:
      for move in moveSection.moves:
        character.moves[move.move_name] = move
    characterLookup[characterName] = character

echo "Populating cache..."
populateCache()
echo "Cache built successfully."

proc findCharacter(characterName: string): Option[Character] =
  let searchedNames = sortByScore(characterName.replace(" ", ""), characterList)
  if searchedNames.len > 0 and characterLookup.hasKey(searchedNames[0]):
    return some(characterLookup[searchedNames[0]])

let moveLookupByAbberviation: Table[string, string] = {
  "nair": "neutral air",
  "bair": "back air",
  "fair": "forward air",
  "dair": "down air",
  "uair": "up air",

  "fsmash": "forward smash",
  "side smash": "forward smash",
  "dsmash": "down smash",
  "usmash": "up smash",

  "ftilt": "forward tilt",
  "side tilt": "forward tilt",
  "utilt": "up tilt",
  "dtilt": "down tilt"
}.toTable()

proc findMove(character: Character, moveName: string): Option[Move] =
  let movesList = character.moves.keys.toSeq()
  let searchTerm = moveLookupByAbberviation.getOrDefault(moveName, movename)
  let searchedMoves = sortByScore(searchTerm, movesList)
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
      resp %("Move \"" & @"move" & "\" for character \"" & character.namePretty & "\" not found.")
    else:
      let response = %* {"character": character.namePretty, "move": moveOpt.get()}
      resp response

