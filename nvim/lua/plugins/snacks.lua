-- snacks.nvim: AstroNvim v6 already wires the picker, notifier, input,
-- indent, scope and words. This adds the dashboard, terminal, lazygit and
-- the toggles that make the rest of the setup feel like one tool.

---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    dashboard = {
      preset = {
        header = table.concat({
          "──── ✦ ────",
          "n e o v i m",
          "──── ✦ ────",
        }, "\n"),
        keys = {
          { icon = " ", key = "f", desc = "Find file", action = "<Leader>ff" },
          { icon = " ", key = "w", desc = "Find word", action = "<Leader>fw" },
          { icon = " ", key = "o", desc = "Recent files", action = "<Leader>fo" },
          { icon = " ", key = "p", desc = "Projects", action = "<Leader>fp" },
          { icon = " ", key = "n", desc = "New file", action = "<Leader>n" },
          { icon = " ", key = "s", desc = "Last session", action = "<Leader>Sl" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header", padding = 2 },
        { section = "keys", gap = 1, padding = 2 },
        { section = "startup" },
      },
    },
    quickfile = { enabled = true },
    terminal = {
      win = { position = "bottom", height = 0.3 },
    },
    lazygit = {
      -- the SilkCircuit installer owns ~/.config/lazygit; don't paint over it
      configure = false,
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local function term(direction)
          return function() require("snacks").terminal.toggle(nil, { win = { position = direction } }) end
        end
        maps.n["<F7>"] = { function() require("snacks").terminal.toggle() end, desc = "Toggle terminal" }
        maps.t["<F7>"] = maps.n["<F7>"]
        maps.i["<F7>"] = { "<Esc><Cmd>lua require('snacks').terminal.toggle()<CR>", desc = "Toggle terminal" }
        maps.n["<Leader>tf"] = { term "float", desc = "Floating terminal" }
        maps.n["<Leader>th"] = { term "bottom", desc = "Horizontal terminal" }
        maps.n["<Leader>tv"] = { term "right", desc = "Vertical terminal" }
        maps.n["<Leader>gg"] = { function() require("snacks").lazygit() end, desc = "Lazygit" }
        maps.n["<Leader>tl"] = maps.n["<Leader>gg"]
        maps.n["<Leader>gf"] = { function() require("snacks").lazygit.log_file() end, desc = "Lazygit file history" }
      end,
    },
  },
}
