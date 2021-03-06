set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'morhetz/gruvbox'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'wincent/command-t'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'wincent/terminus'
Plugin 'scrooloose/syntastic'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()

syntax on

filetype plugin indent on
set encoding=utf-8
set guifont=DroidSansMono\ Nerd\ Font\ 11
colorscheme gruvbox
color gruvbox
let g:airline_theme = 'term'

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

" Show what mode you're currently in
set showmode

" Show what commands you're typing
set showcmd

" Allow modelines
set modeline

" Show current line and column position in file
set ruler

" Show file title in terminal tab
set title

" Show line numbers
set number

" Always display the status line
set laststatus=2

" Highlight current line
"set cursorline

" Highlight search results as we type
set incsearch

" ignore case when searching...
set ignorecase

" ...except if we input a capital letter
set smartcase

" hides buffer instead of closing them
set hidden

" Tab stuff
set tabstop=4
set shiftwidth=4
set autoindent

set noeb vb t_vb=

let mapleader=" "
let g:mapleader=" "
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>q :q!<cr>
nnoremap <leader>z :wq<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>v <C-w>v<C-w>l " Split then move to the split
nnoremap <leader>n :bnext<cr> " Next
nnoremap <leader>N :bprev<cr>
nnoremap <leader>r :source ~/.vimrc<cr> " Reset/reload config
noremap <leader>s :!%:p<cr> " Source (execute) current file

autocmd BufWritePre * :%s/\s\+$//e

set splitbelow
set splitright

" Buffer navigation
noremap <Leader>] :bnext<CR>
noremap <Leader>[ :bprev<CR>

" bbye remap to w
noremap <Leader>w :Bdelete<CR>

" Navigate panes with control
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" NERDTree
let NERDTreeShowHidden = 1
let NERDTreeMapOpenSplit = '<C-x>'
let NERDTreeMapOpenVSplit = '<C-v>'
let NERDTreeMapOpenInTab = '<C-t>'
" open NERDTree automatically on vim start, even if no file is specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" open NERDTree with `Ctrl-n`
map <C-n> :NERDTreeToggle<CR>

" Syntastic recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" make ESC key work for command-t
if &term =~ "xterm" || &term =~ "screen"
    let g:CommandTCancelMap = ['<ESC>', '<C-c>']
endif

" Disable JSON quote concealing
let g:vim_json_syntax_conceal = 0
let g:ctrlp_show_hidden = 1

" ycm
" <Enter> key completion
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']

if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif

hi Normal     ctermbg=NONE guibg=NONE
hi LineNr     ctermbg=NONE guibg=NONE
hi SignColumn ctermbg=NONE guibg=NONE
hi VertSplit  ctermbg=NONE guibg=NONE
