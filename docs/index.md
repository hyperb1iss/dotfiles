---
layout: home

hero:
  name: Dotfiles
  text: SilkCircuit Edition
  tagline:
    Your terminal shouldn't just work—it should feel electric. A development environment where cyberpunk aesthetics meet
    modern productivity.
  image:
    src: /logo.svg
    alt: SilkCircuit Logo
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/
    - theme: alt
      text: View on GitHub
      link: https://github.com/hyperb1iss/dotfiles

features:
  - icon: ⚡
    title: Shell Built for Speed
    details:
      25+ modular shell scripts, 100+ intelligent aliases, and fzf-powered fuzzy finding. Jump anywhere, do anything,
      faster than thought.
  - icon: ✨
    title: Neovim That Sparks Joy
    details:
      AstroNvim foundation with LSP perfection, Claude AI integration, and the custom SilkCircuit theme. Code editing as
      it should be.
  - icon: 🎨
    title: Electric Aesthetic Everywhere
    details:
      Neon cyberpunk vibes flow through Neovim, Starship prompt, Tmux, Git Delta, and every CLI tool. Consistent,
      cohesive, captivating.
  - icon: 🚀
    title: Modern CLI Arsenal
    details:
      lsd over ls. bat over cat. ripgrep, fd, delta, zoxide—battle-tested modern replacements that just work better.
  - icon: 🔧
    title: Cross-Platform Intelligence
    details: Seamless on macOS, Linux, and WSL2 with smart platform detection. One config, every environment.
  - icon: 🎯
    title: Zero Friction Setup
    details:
      Run make and watch the magic happen. Sensible defaults, smart bootstrapping, no config hell. Ready in minutes.
---

<style>
:root {
  --vp-home-hero-name-color: transparent;
  --vp-home-hero-name-background: linear-gradient(135deg, #e135ff 0%, #80ffea 50%, #ff6ac1 100%);
  --vp-home-hero-image-background-image: linear-gradient(135deg, #e135ff33 0%, #80ffea33 50%, #ff6ac133 100%);
  --vp-home-hero-image-filter: blur(44px);
}

.dark {
  --vp-home-hero-image-background-image: linear-gradient(135deg, #e135ff66 0%, #80ffea66 50%, #ff6ac166 100%);
}

@media (min-width: 640px) {
  .VPHero .main {
    max-width: 820px !important;
  }

  .VPHero .tagline {
    max-width: 720px !important;
    line-height: 1.6 !important;
  }
}
</style>
