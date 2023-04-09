import std/[algorithm, strutils, sequtils, tables]

template areLettersSameCase(letterA, letterB: char): bool =
  isLowerAscii(letterA) == isLowerAscii(letterB)

func score*(needle, haystack: string): float =
  ## Returns:
  ## -1 if the needle contains letters the haystack does not contain,
  ## or if the needle length exceeds the haystack length.
  ##
  ## 0 if no similarities were found
  ##
  ## > 0 based on similarities between the needle and haystack (increasing)
  let needleLength = needle.len()
  let haystackLength = haystack.len()
  if needleLength > haystackLength:
    return -1.0

  if needleLength == 0:
    return 0.0

  let lowerNeedle = needle.toLowerAscii()
  let lowerHaystack = haystack.toLowerAscii()

  var i, j = 0
  while i < needleLength and j < haystackLength:
    let letter = lowerNeedle[i]
    let letterIndex = lowerHaystack.find(letter, j)
    if letterIndex - j < 0:
      return -1

    if areLettersSameCase(needle[i], haystack[j]):
      result += 0.5

    if letterIndex == j:
      # Letter was consecutive
      result += 8.0
    else:
      result += 1.0 - (0.1 * float(letterIndex))
      # Move j up to the next found letter.
      j = letterIndex

    if j == haystackLength - 1 and i < needleLength - 1:
      return -1.0

    i += 1
    j += 1

proc sortByScore*(needle: string, haystacks: openArray[string]): seq[string] =
  ## Sorts the haystack by score (best match first).
  var scoreTable = initTable[string, float]()
  for haystack in haystacks:
    scoreTable[haystack] = score(needle, haystack)

  var pairs = scoreTable.pairs.toSeq
  pairs.sort do (x, y: (string, float)) -> int:
    result = cmp(y[1], x[1])
    if result == 0:
      result = cmp(x[0], y[0])

  for pair in pairs:
    if pair[1] >= 0:
      result.add(pair[0])

