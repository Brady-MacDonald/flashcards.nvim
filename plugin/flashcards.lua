if vim.g.loaded_flashcards then
  return
end
vim.g.loaded_flashcards = true

vim.api.nvim_create_user_command("Flashcards", function(args)
  require("flashcards").start(args.args ~= "" and args.args or nil)
end, {
  nargs = "?",
  complete = function(lead)
    return vim.tbl_filter(function(n)
      return n:find(lead, 1, true) == 1
    end, require("flashcards").complete())
  end,
  desc = "Open flashcards",
})

vim.api.nvim_create_user_command("FlashcardsConjugate", function(args)
  require("flashcards").conjugate(args.fargs)
end, {
  nargs = "*",
  complete = function(lead)
    local conj = require("flashcards.conjugate")
    local items = vim.list_extend(vim.deepcopy(conj.tenses), vim.tbl_keys(conj.verbs))
    table.sort(items)
    return vim.tbl_filter(function(n)
      return n:find(lead, 1, true) == 1
    end, items)
  end,
  desc = "Spanish verb conjugation drill",
})
