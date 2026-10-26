local config = require("flashcards.config")

local M = {}

function M.setup(opts)
  config.setup(opts)
end

function M.complete()
  return require("flashcards.deck").list(config.options.decks_dir)
end

function M.start(name)
  local deck = require("flashcards.deck")
  local path, err = deck.resolve(name, config.options)
  if not path then
    return vim.notify("flashcards: " .. err, vim.log.levels.ERROR)
  end
  local d, lerr = deck.load(path)
  if not d then
    return vim.notify("flashcards: " .. lerr, vim.log.levels.ERROR)
  end
  local session = require("flashcards.session").new(d, config.options.shuffle)
  require("flashcards.ui").open(session)
end

return M
