export function isMultiLineString(string) {
  return /\r|\n/.test(string)
}

export function normalizeFilteredText(string) {
  return string
    .toLowerCase()
    .normalize("NFD").replace(/[\u0300-\u036f]/g, "") // Remove diacritics
}

export function filterMatches(text, potentialMatch) {
  return normalizeFilteredText(text).includes(normalizeFilteredText(potentialMatch))
}

export function toSentence(array, options = {}) {
  const defaultConnectors = {
    words_connector: ", ",
    two_words_connector: " and ",
    last_word_connector: ", and "
  }

  const connectors = { ...defaultConnectors, ...options }

  if (array.length === 0) {
    return ""
  }

  if (array.length === 1) {
    return array[0]
  }

  if (array.length === 2) {
    return array.join(connectors.two_words_connector)
  }

  return array.slice(0, -1).join(connectors.words_connector) + connectors.last_word_connector + array[array.length - 1]
}
