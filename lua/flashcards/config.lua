local M = {}

M.defaults = {
  decks_dir = vim.fn.stdpath("data") .. "/flashcards",
  default_deck = nil,
  shuffle = true,
  window = { width = 50, height = 10, border = "rounded" },
  keys = {
    reveal = { "<Space>", "<CR>" },
    next = { "n", "l" },
    prev = { "p", "h" },
    restart = "r",
    close = { "q", "<Esc>" },
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  return M.options
end

return M
