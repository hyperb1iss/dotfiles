-- AstroUI configuration for SilkCircuit theme

return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "silkcircuit",

    status = {
      colorscheme = "silkcircuit",
      separators = require("silkcircuit.contrib.astronvim").separators,
      colors = require("silkcircuit.contrib.astronvim").status_colors,
    },
  },
}
