import std/[json, os, strformat, strutils, options, sequtils, uri, algorithm]
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
    moves: Table[string, Move]

proc newCharacter(name: string): Character =
  return Character(name: name, moves: initTable[string, Move]())

var characterLookup = initTable[string, Character]()

proc populateCache() =
  for file in walkFiles("./data/*.json"):
    let json = parseFile(file)
    let characterName = splitFile(file).name
    let characterJson = json.to(CharacterJson)
    var character = newCharacter(characterName)
    for moveSection in characterJson.move_sections:
      for move in moveSection.moves:
        character.moves[move.move_name] = move
    characterLookup[characterName] = character

echo "Populating cache..."
populateCache()
echo "Cache built successfully."

proc findMove(character: Character, moveName: string): Option[Move] =
  let movesList = character.moves.keys.toSeq()
  let searchedMoves = sortByScore(moveName, movesList)
  if searchedMoves.len > 0:
    return some(character.moves[searchedMoves[0]])

routes:
  get "/characters":
    resp %characterList

  get "/characters/@character/@move":
    if not characterLookup.hasKey(@"character"):
      resp %"No character found with that name"

    let character = characterLookup[@"character"]
    let moveQuery = decodeUrl(@"move")
    let moveOpt = findMove(character, moveQuery)
    if moveOpt.isNone:
      resp %("Move \"" & @"move" & "\" for character \"" & character.name & "\" not found.")
    else:
      let response = %* {"character": character.name, "move": moveOpt.get()}
      resp response

