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

---Start a conjugation drill. args: any mix of tense names and verbs.
function M.conjugate(args)
  local conj = require("flashcards.conjugate")
  local tenses, verbs = {}, {}
  for _, a in ipairs(args or {}) do
    if vim.tbl_contains(conj.tenses, a) then
      table.insert(tenses, a)
    elseif conj.verbs[a] then
      table.insert(verbs, a)
    else
      return vim.notify("flashcards: unknown tense or verb: " .. a, vim.log.levels.ERROR)
    end
  end
  local session = require("flashcards.session").new(conj.deck(tenses, verbs), config.options.shuffle)
  require("flashcards.ui").open(session)
end

return M
