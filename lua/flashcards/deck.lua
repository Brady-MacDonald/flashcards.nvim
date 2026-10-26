local M = {}

---Resolve a deck name or path to a file path.
function M.resolve(name, opts)
  name = name or opts.default_deck
  if not name then
    local files = M.list(opts.decks_dir)
    if #files == 1 then
      name = files[1]
    else
      return nil, "No deck specified (set default_deck or pass a name)"
    end
  end
  if name:sub(1, 1) == "/" or name:sub(1, 1) == "~" then
    return vim.fn.expand(name)
  end
  return opts.decks_dir .. "/" .. name:gsub("%.json$", "") .. ".json"
end

function M.list(dir)
  local out = {}
  for _, f in ipairs(vim.fn.glob(dir .. "/*.json", false, true)) do
    table.insert(out, vim.fn.fnamemodify(f, ":t:r"))
  end
  table.sort(out)
  return out
end

---Load and validate. Returns deck or nil, err.
function M.load(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil, "Cannot read deck: " .. path
  end
  local content = fd:read("*a")
  fd:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return nil, "Invalid JSON in " .. path
  end
  if type(data.cards) ~= "table" then
    return nil, "Deck has no 'cards' array"
  end
  local cards, skipped = {}, 0
  for _, c in ipairs(data.cards) do
    if type(c) == "table" and type(c.front) == "string" and type(c.back) == "string" then
      table.insert(cards, { front = c.front, back = c.back, note = type(c.note) == "string" and c.note or nil })
    else
      skipped = skipped + 1
    end
  end
  if skipped > 0 then
    vim.notify(("flashcards: skipped %d invalid card(s)"):format(skipped), vim.log.levels.WARN)
  end
  if #cards == 0 then
    return nil, "Deck has no valid cards"
  end
  return { name = type(data.name) == "string" and data.name or vim.fn.fnamemodify(path, ":t:r"), cards = cards }
end

return M
