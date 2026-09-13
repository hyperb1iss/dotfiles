# Neovim

AstroNvim v6 on Neovim 0.12, themed by [SilkCircuit](https://github.com/hyperb1iss/silkcircuit).
`~/.config/nvim` links here.

- `lua/community.lua` picks the language packs and community recipes.
- `lua/plugins/` holds the overrides. Files named after a plugin configure it;
  `disabled.lua` turns off core plugins this setup replaces.
- `lua/plugins/{astroui,neo-tree,silkcircuit}.lua` are copied in by the
  SilkCircuit installer and listed in `.styluaignore`; edit them in that repo.

The full tour lives in `docs/neovim/`.
