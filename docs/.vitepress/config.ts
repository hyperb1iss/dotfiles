import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Dotfiles',
  description: 'SilkCircuit-powered development environment',
  base: '/dotfiles/',

  head: [
    ['link', { rel: 'icon', href: '/dotfiles/favicon.svg' }],
    ['meta', { name: 'theme-color', content: '#e135ff' }],
    ['meta', { name: 'og:type', content: 'website' }],
    ['meta', { name: 'og:title', content: 'Dotfiles - SilkCircuit Edition' }],
    ['meta', { name: 'og:description', content: 'Electric terminal environment with cyberpunk aesthetics' }],
  ],

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'Dotfiles',

    nav: [
      { text: 'Guide', link: '/getting-started/' },
      { text: 'Shell', link: '/shell/' },
      { text: 'Neovim', link: '/neovim/' },
      { text: 'Tools', link: '/tools/' },
      {
        text: 'Reference',
        items: [
          { text: 'All Aliases', link: '/reference/aliases' },
          { text: 'All Functions', link: '/reference/functions' },
          { text: 'Keybindings', link: '/reference/keybindings' },
        ],
      },
    ],

    sidebar: {
      '/getting-started/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/getting-started/' },
            { text: 'Installation', link: '/getting-started/installation' },
            { text: 'Quick Start', link: '/getting-started/quick-start' },
            { text: 'Configuration', link: '/getting-started/configuration' },
          ],
        },
      ],
      '/shell/': [
        {
          text: 'Shell Environment',
          items: [
            { text: 'Overview', link: '/shell/' },
            { text: 'Zsh Setup', link: '/shell/zsh' },
            { text: 'Git Utilities', link: '/shell/git' },
            { text: 'Directory Navigation', link: '/shell/directory' },
            { text: 'Docker', link: '/shell/docker' },
            { text: 'Kubernetes', link: '/shell/kubernetes' },
            { text: 'TypeScript & Turbo', link: '/shell/typescript' },
          ],
        },
        {
          text: 'Language Support',
          items: [
            { text: 'Node.js / NVM', link: '/shell/nvm' },
            { text: 'Python', link: '/shell/python' },
            { text: 'Rust', link: '/shell/rust' },
            { text: 'Java', link: '/shell/java' },
          ],
        },
        {
          text: 'System Utilities',
          items: [
            { text: 'Network', link: '/shell/network' },
            { text: 'System Info', link: '/shell/system' },
            { text: 'Process Management', link: '/shell/process' },
            { text: 'macOS Utilities', link: '/shell/macos' },
          ],
        },
      ],
      '/neovim/': [
        {
          text: 'Neovim',
          items: [
            { text: 'Overview', link: '/neovim/' },
            { text: 'Plugins', link: '/neovim/plugins' },
            { text: 'Keymaps', link: '/neovim/keymaps' },
            { text: 'LSP & Completion', link: '/neovim/lsp' },
            { text: 'AI Integration', link: '/neovim/ai' },
          ],
        },
      ],
      '/tools/': [
        {
          text: 'CLI Tools',
          items: [
            { text: 'Overview', link: '/tools/' },
            { text: 'Starship Prompt', link: '/tools/starship' },
            { text: 'Tmux', link: '/tools/tmux' },
            { text: 'FZF', link: '/tools/fzf' },
            { text: 'Modern CLI', link: '/tools/modern-cli' },
          ],
        },
      ],
      '/reference/': [
        {
          text: 'Reference',
          items: [
            { text: 'All Aliases', link: '/reference/aliases' },
            { text: 'All Functions', link: '/reference/functions' },
            { text: 'Keybindings', link: '/reference/keybindings' },
          ],
        },
      ],
    },

    socialLinks: [{ icon: 'github', link: 'https://github.com/hyperb1iss/dotfiles' }],

    footer: {
      message: 'Released under the MIT License',
      copyright: 'Copyright © Stefanie Jane',
    },

    search: {
      provider: 'local',
    },

    editLink: {
      pattern: 'https://github.com/hyperb1iss/dotfiles/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },
  },

  markdown: {
    theme: {
      light: 'github-light',
      dark: 'one-dark-pro',
    },
    lineNumbers: true,
  },
});
