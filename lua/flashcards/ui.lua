local config = require("flashcards.config")

local M = {}
local ns = vim.api.nvim_create_namespace("flashcards")
local state = nil

local function hl()
  local set = function(name, link)
    vim.api.nvim_set_hl(0, name, { link = link, default = true })
  end
  set("FlashcardsFront", "Title")
  set("FlashcardsBack", "String")
  set("FlashcardsHint", "Comment")
end

local function center(text, width)
  local w = vim.fn.strdisplaywidth(text)
  return string.rep(" ", math.max(0, math.floor((width - w) / 2))) .. text
end

local function geometry()
  local w = config.options.window
  local width = math.min(w.width, vim.o.columns - 4)
  local height = math.min(w.height, vim.o.lines - 4)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  }
end

local function first_key(k)
  if type(k) == "table" then
    return k[1] or "?"
  end
  return k or "?"
end

local function render()
  local s = state
  local width = vim.api.nvim_win_get_width(s.win)
  local height = vim.api.nvim_win_get_height(s.win)
  local keys = config.options.keys
  local lines, marks = {}, {}
  local function add(text, group)
    table.insert(lines, center(text, width))
    if group then
      table.insert(marks, { #lines - 1, group })
    end
  end

  local session = s.session
  if session.done then
    add("Deck complete!", "FlashcardsFront")
    add("")
    add(("press %s to restart, %s to close"):format(first_key(keys.restart), first_key(keys.close)), "FlashcardsHint")
  else
    local card = session:current()
    add(card.front, "FlashcardsFront")
    if session.revealed then
      add(string.rep("─", math.floor(width / 2)))
      add(card.back, "FlashcardsBack")
      if card.note then
        add("")
        add(card.note, "FlashcardsHint")
      end
    else
      add("")
      add(("press %s to reveal"):format(first_key(keys.reveal)), "FlashcardsHint")
    end
  end

  local top = math.max(0, math.floor((height - #lines) / 2))
  for _ = 1, top do
    table.insert(lines, 1, "")
  end

  vim.bo[s.buf].modifiable = true
  vim.api.nvim_buf_set_lines(s.buf, 0, -1, false, lines)
  vim.bo[s.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(s.buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(s.buf, ns, m[1] + top, 0, { line_hl_group = m[2] })
  end

  local pos = session.done and #session.queue or session.index
  vim.api.nvim_win_set_config(s.win, {
    title = " " .. session.deck.name .. " ",
    title_pos = "center",
    footer = (" %d/%d "):format(pos, #session.queue),
    footer_pos = "center",
  })
end

function M.close()
  if not state then
    return
  end
  local s = state
  state = nil
  pcall(vim.api.nvim_del_augroup_by_id, s.group)
  if vim.api.nvim_win_is_valid(s.win) then
    vim.api.nvim_win_close(s.win, true)
  end
end

local function map(lhs, fn)
  if not lhs then
    return
  end
  for _, key in ipairs(type(lhs) == "table" and lhs or { lhs }) do
    vim.keymap.set("n", key, fn, { buffer = state.buf, nowait = true, silent = true })
  end
end

function M.open(session)
  M.close()
  hl()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "flashcards"

  local win = vim.api.nvim_open_win(buf, true, vim.tbl_extend("force", geometry(), {
    style = "minimal",
    border = config.options.window.border,
  }))
  local group = vim.api.nvim_create_augroup("FlashcardsUI", { clear = true })
  state = { buf = buf, win = win, session = session, group = group }

  local keys = config.options.keys
  local function act(fn)
    return function()
      fn()
      render()
    end
  end
  map(keys.reveal, act(function()
    if not session.done then
      session:reveal()
    end
  end))
  map(keys.next, act(function()
    session:next()
  end))
  map(keys.prev, act(function()
    session:prev()
  end))
  map(keys.restart, act(function()
    session:restart()
  end))
  map(keys.close, M.close)

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(win),
    callback = function()
      M.close()
    end,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if state and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_set_config(state.win, geometry())
        render()
      end
    end,
  })
  render()
end

return M
