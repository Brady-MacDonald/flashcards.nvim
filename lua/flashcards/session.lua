local Session = {}
Session.__index = Session

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function Session.new(deck, do_shuffle)
  local self = setmetatable({ deck = deck, do_shuffle = do_shuffle }, Session)
  self:restart()
  return self
end

function Session:restart()
  self.queue = vim.list_slice(self.deck.cards)
  if self.do_shuffle then
    shuffle(self.queue)
  end
  self.index = 1
  self.revealed = false
  self.done = false
end

function Session:current()
  return self.queue[self.index]
end

function Session:reveal()
  self.revealed = true
end

function Session:next()
  if self.index >= #self.queue then
    self.done = true
    return
  end
  self.index = self.index + 1
  self.revealed = false
end

function Session:prev()
  if self.done then
    self.done = false
    self.revealed = false
    return
  end
  if self.index > 1 then
    self.index = self.index - 1
    self.revealed = false
  end
end

return Session
