" ---
" VimPlug
" ---
" Download and use vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/plug/vim-plug/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !mkdir -p ~/.config/nvim/autoload && cd ~/.config/nvim/autoload && ln -s ../plug/vim-plug/plug.vim .
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')

Plug 'christoomey/vim-tmux-navigator'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimfiler.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'easymotion/vim-easymotion'
Plug 'mhinz/vim-startify'
Plug 'kshenoy/vim-signature'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'WolfgangMehner/lua-support'
Plug 'tpope/vim-dispatch'
Plug 'Chiel92/vim-autoformat'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'scrooloose/syntastic'
"Plug 'gilligan/vim-lldb'
Plug 'critiqjo/lldb.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-scripts/c.vim'
Plug 'tikhomirov/vim-glsl'
Plug 'mileszs/ack.vim'
Plug 'powerman/vim-plugin-viewdoc'
Plug 'rizzatti/dash.vim'
"Plug 'rdnetto/YCM-Generator'
Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --clang-completer' }
Plug 'reewr/vim-monokai-phoenix'
Plug 'zcodes/vim-colors-basic'
Plug 'junegunn/fzf', { 'dir': '~/dev/dotfiles/fzf', 'do': './install --all' }
Plug 'rhysd/vim-clang-format'

call plug#end()

" ---
" Theme
" ---
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
if (has("termguicolors"))
 set termguicolors
endif
set background=dark
syntax enable
"let g:rehash256 = 1
set t_Co=256
set t_ut=
colorscheme basic-dark

set fillchars+=vert:│

"
" ---
" Nerdtree
" ---
" Autoclose when closing last buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeMinimalUI=1
let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1

" ---
" Tagbar
" ---
let g:tagbar_compact = 1

" ---
" You Complete Me
" ---
let g:ycm_register_as_syntastic_checker = 1 "default 1
let g:Show_diagnostics_ui = 1 "default 1

"will put icons in Vim's gutter on lines that have a diagnostic set.
"Turning this off will also turn off the YcmErrorLine and YcmWarningLine
"highlighting
let g:ycm_auto_trigger = 1
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_enable_diagnostic_highlighting = 1
let g:ycm_always_populate_location_list = 1 "default 0
let g:ycm_open_loclist_on_ycm_diags = 1 "default 1

"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_autoclose_preview_window_after_insertion = 1

let g:ycm_complete_in_strings = 1 "default 1
let g:ycm_collect_identifiers_from_tags_files = 1 "default 0
"let g:ycm_path_to_python_interpreter = '' "default ''

let g:ycm_server_use_vim_stdout = 0 "default 0 (logging to console)
let g:ycm_server_log_level = 'info' "default info

let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'  "where to search for .ycm_extra_conf.py if not found
let g:ycm_confirm_extra_conf = 0

let g:ycm_goto_buffer_command = 'same-buffer' "[ 'same-buffer', 'horizontal-split', 'vertical-split', 'new-tab' ]
let g:ycm_filetype_whitelist = { '*': 1 }
let g:ycm_key_invoke_completion = '<C-Space>'

let g:ycm_warning_symbol = '?'
let g:ycm_error_symbol = '!'

let g:ycm_semantic_triggers =  {
    \   'c' : ['->', '.'],
    \   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
    \             're!\[.*\]\s'],
    \   'ocaml' : ['.', '#'],
    \   'cpp,objcpp' : ['->', '.', '::'],
    \   'perl' : ['->'],
    \   'php' : ['->', '::'],
    \   'cs,java,javascript,typescript,d,python,perl6,scala,vb,elixir,go' : ['.'],
    \   'ruby' : ['.', '::'],
    \   'lua' : ['.', ':'],
    \   'erlang' : [':'],
    \ }

nnoremap <F11> :YcmForceCompileAndDiagnostics <CR>
"let g:ycm_server_keep_logfiles = 1
"let g:ycm_server_log_level = 'debug'

" ---
" GitGutter Symbols
" ---
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '±'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '='

" ---
" AirLine
" ---
" Set theme
"let g:airline_theme = 'powerlineish'

" Show airline with single file
set laststatus=2
" Use powerline font
let g:airline_powerline_fonts = 1
" Enable tabline
"let g:airline#extensions#tabline#enabled = 1

" ---
" Settings
" ---
set hidden
set mouse=

"set nowrap        " don't wrap lines
set backspace=indent,eol,start
" allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set nonumber        " don't show line numbers
set shiftwidth=2  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
" case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
" shiftwidth, not tabstop
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
set encoding=utf-8
set showcmd
set smartcase

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

filetype plugin indent on

set listchars=tab:›\ ,eol:¬   " Use the same symbols as TextMate for tabstops and EOLs

syntax enable
set nocompatible

" Tab behavior
set smarttab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

set clipboard=unnamed

" ---
" Post Load Fixes
" ---
function CorrectColorScheme()
  " Annoying tilde should be hidden
  highlight EndOfBuffer ctermfg=0 guifg=#282828

  highlight VertSplit ctermbg=NONE guifg=#404040 guibg=NONE
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE

endfunction
autocmd VimEnter * call CorrectColorScheme()

" ---
" Mappings
" ---
let mapleader=" "

map <leader>l :set list!<CR>
map <leader>w :set wrap!<CR>
map <leader>n :NERDTreeToggle<CR>
map <leader>m :TagbarToggle<CR>

map <leader>, :bp!<CR>
map <leader>. :bn!<CR>
map <leader>x :bd<CR>

nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gs :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gt :YcmCompleter GetType<CR>
nnoremap <leader>gp :YcmCompleter GetParent<CR>
nnoremap <leader>f :YcmCompleter FixIt<CR>

nmap <silent> <leader>d <Plug>DashSearch

" Destroy all trailing whitespace
function TrimWhiteSpace()
  %s/\s*$//
  ''
endfunction

" autocmd FileWritePre * call TrimWhiteSpace()
" autocmd FileAppendPre * call TrimWhiteSpace()
" autocmd FilterWritePre * call TrimWhiteSpace()
" autocmd BufWritePre * call TrimWhiteSpace()

map <F2> :call TrimWhiteSpace()<CR>
map! <F2> :call TrimWhiteSpace()<CR>
