# UFD

REST API for https://ultimateframedata.com/

## Initial design

List of endpoints/examples (WIP):

- `GET /characters` returns a list of character names
- `GET /characters/mario/ftilt` to retrieve all data on Mario's forward tilt.
  A case-insensitive fuzzy search will be used to determine the closest match to a move's name,
  to prevent issue with some move names like `"Rage Drive (Non Input)"` for Kazuya.

