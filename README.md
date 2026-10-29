# flashcards.nvim

Simple floating-window flashcards for Neovim. Shows the front of a card; press a key to reveal the back.

## Usage

`:Flashcards [deck]` — deck is a name in `decks_dir` (without `.json`) or an absolute path.

`:FlashcardsConjugate [tense|verb ...]` — Spanish verb conjugation drill, generated on the fly. Tenses: `present`, `preterite`, `imperfect`, `future`, `conditional`. Examples: `:FlashcardsConjugate preterite`, `:FlashcardsConjugate tener ir ser present`. No arguments drills every verb in every tense. Verbs and irregulars live in `lua/flashcards/conjugate.lua`.

## Deck format

```json
{ "name": "Spanish basics", "cards": [ { "front": "hola", "back": "hello", "note": "optional" } ] }
```

## Config (lazy.nvim)

```lua
{
  dir = vim.fn.expand("~/Brady-MacDonald/flashcards.nvim"),
  cmd = "Flashcards",
  opts = {
    decks_dir = vim.fn.stdpath("data") .. "/flashcards",
    default_deck = nil,
    shuffle = true,
    window = { width = 50, height = 10, border = "rounded" },
    keys = { -- string, list, or false to disable
      reveal = { "<Space>", "<CR>" },
      next = { "n", "l" },
      prev = { "p", "h" },
      restart = "r",
      close = { "q", "<Esc>" },
    },
  },
}
```

Highlights: `FlashcardsFront`, `FlashcardsBack`, `FlashcardsHint`.
