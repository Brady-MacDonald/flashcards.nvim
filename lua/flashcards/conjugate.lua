local M = {}

M.persons = { "yo", "tú", "él/ella/usted", "nosotros", "vosotros", "ellos/ellas" }
M.tenses = { "present", "preterite", "imperfect", "future", "conditional" }

-- verb = english meaning
M.verbs = {
  hablar = "to speak", trabajar = "to work", estudiar = "to study", comprar = "to buy",
  llegar = "to arrive", caminar = "to walk", comer = "to eat", beber = "to drink",
  aprender = "to learn", correr = "to run", vivir = "to live", escribir = "to write",
  abrir = "to open", ser = "to be (essence)", estar = "to be (state/location)", ir = "to go",
  tener = "to have", venir = "to come", hacer = "to do/make", decir = "to say/tell",
  poder = "to be able to", querer = "to want", saber = "to know (facts)", poner = "to put",
  salir = "to leave", dar = "to give", ver = "to see", traer = "to bring",
  dormir = "to sleep", pedir = "to ask for", volver = "to return", pensar = "to think",
  jugar = "to play", seguir = "to follow/continue",
}

local endings = {
  present = {
    ar = { "o", "as", "a", "amos", "áis", "an" },
    er = { "o", "es", "e", "emos", "éis", "en" },
    ir = { "o", "es", "e", "imos", "ís", "en" },
  },
  preterite = {
    ar = { "é", "aste", "ó", "amos", "asteis", "aron" },
    er = { "í", "iste", "ió", "imos", "isteis", "ieron" },
    ir = { "í", "iste", "ió", "imos", "isteis", "ieron" },
  },
  imperfect = {
    ar = { "aba", "abas", "aba", "ábamos", "abais", "aban" },
    er = { "ía", "ías", "ía", "íamos", "íais", "ían" },
    ir = { "ía", "ías", "ía", "íamos", "íais", "ían" },
  },
  future = { "é", "ás", "á", "emos", "éis", "án" },
  conditional = { "ía", "ías", "ía", "íamos", "íais", "ían" },
}

-- Fully irregular conjugations (whole tense)
local full = {
  ser = {
    present = { "soy", "eres", "es", "somos", "sois", "son" },
    preterite = { "fui", "fuiste", "fue", "fuimos", "fuisteis", "fueron" },
    imperfect = { "era", "eras", "era", "éramos", "erais", "eran" },
  },
  estar = { present = { "estoy", "estás", "está", "estamos", "estáis", "están" } },
  ir = {
    present = { "voy", "vas", "va", "vamos", "vais", "van" },
    preterite = { "fui", "fuiste", "fue", "fuimos", "fuisteis", "fueron" },
    imperfect = { "iba", "ibas", "iba", "íbamos", "ibais", "iban" },
  },
  dar = {
    present = { "doy", "das", "da", "damos", "dais", "dan" },
    preterite = { "di", "diste", "dio", "dimos", "disteis", "dieron" },
  },
  ver = {
    present = { "veo", "ves", "ve", "vemos", "veis", "ven" },
    preterite = { "vi", "viste", "vio", "vimos", "visteis", "vieron" },
    imperfect = { "veía", "veías", "veía", "veíamos", "veíais", "veían" },
  },
  hacer = { preterite = { "hice", "hiciste", "hizo", "hicimos", "hicisteis", "hicieron" } },
}

-- Present: stem change applies to yo/tú/él/ellos
local stem_change = {
  tener = "tien", venir = "vien", decir = "dic", poder = "pued", querer = "quier",
  volver = "vuelv", dormir = "duerm", pedir = "pid", pensar = "piens", jugar = "jueg",
  seguir = "sig",
}
local yo_irregular = {
  tener = "tengo", venir = "vengo", hacer = "hago", decir = "digo", poner = "pongo",
  salir = "salgo", traer = "traigo", saber = "sé", seguir = "sigo",
}
-- Preterite irregular stems (endings: e iste o imos isteis ieron / eron after j)
local pret_stem = {
  estar = "estuv", tener = "tuv", poder = "pud", poner = "pus", saber = "sup",
  querer = "quis", venir = "vin", decir = "dij", traer = "traj",
}
-- -ir stem-changing verbs in the preterite (3rd person only)
local pret_ir_change = { dormir = "durm", pedir = "pid", seguir = "sigu" }
local fut_stem = {
  tener = "tendr", venir = "vendr", poder = "podr", querer = "querr", saber = "sabr",
  poner = "pondr", salir = "saldr", hacer = "har", decir = "dir",
}
local imperfect_stem = { traer = nil }

-- Spelling changes in the preterite yo form
local function pret_yo_spelling(verb, form)
  if verb == "llegar" then return "llegué" end
  if verb == "jugar" then return "jugué" end
  return form
end

function M.conjugate(verb, tense)
  if full[verb] and full[verb][tense] then
    return vim.deepcopy(full[verb][tense])
  end
  local kind = verb:sub(-2)
  local stem = verb:sub(1, -3)
  local out = {}

  if tense == "future" or tense == "conditional" then
    local base = fut_stem[verb] or verb
    for i, e in ipairs(endings[tense]) do out[i] = base .. e end
    return out
  end

  if tense == "preterite" and pret_stem[verb] then
    local e = { "e", "iste", "o", "imos", "isteis", "ieron" }
    if pret_stem[verb]:sub(-1) == "j" then e[6] = "eron" end
    for i = 1, 6 do out[i] = pret_stem[verb] .. e[i] end
    return out
  end

  local e = endings[tense][kind]
  for i = 1, 6 do out[i] = stem .. e[i] end

  if tense == "present" then
    local sc = stem_change[verb]
    if sc then
      for _, i in ipairs({ 1, 2, 3, 6 }) do out[i] = sc .. e[i] end
    end
    if yo_irregular[verb] then out[1] = yo_irregular[verb] end
    if verb == "jugar" then out[4], out[5] = "jugamos", "jugáis" end
  elseif tense == "preterite" then
    local c = pret_ir_change[verb]
    if c then
      out[3], out[6] = c .. e[3], c .. e[6]
      if verb == "seguir" then out[3], out[6] = "sigu" .. e[3], "sigu" .. e[6] end
    end
    out[1] = pret_yo_spelling(verb, out[1])
    if verb == "leer" then out[3], out[6] = "leyó", "leyeron" end
  end
  return out
end

---Build a deck. `tenses` and `verbs` are optional filter lists.
function M.deck(tenses, verbs)
  tenses = (tenses and #tenses > 0) and tenses or M.tenses
  if not verbs or #verbs == 0 then
    verbs = vim.tbl_keys(M.verbs)
    table.sort(verbs)
  end
  local cards = {}
  for _, v in ipairs(verbs) do
    for _, t in ipairs(tenses) do
      local forms = M.conjugate(v, t)
      for i, p in ipairs(M.persons) do
        table.insert(cards, {
          front = ("%s — %s (%s)"):format(v, p, t),
          back = forms[i],
          note = M.verbs[v],
        })
      end
    end
  end
  return { name = "Conjugation", cards = cards }
end

return M
