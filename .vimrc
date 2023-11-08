set encoding=utf-8

set mouse=a
set cursorline

syntax on

set number
set ai
set ruler

" tab
set cindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" indent line(not working)
set listchars=tab:¦\  
set list

" search
set hls
set hlsearch
set incsearch

" clipboard
set clipboard=unnamed "OSX
if system('uname -s') == "Darwin\n"
    set clipboard=unnamed "OSX
    else
        set clipboard=unnamedplus "Linux
endif

" backspace suddenly breakdown, only can delete new char
set backspace=indent,eol,start

filetype plugin indent on
filetype plugin on

" fold function, class,...
set foldmethod=indent
set foldminlines=0
nnoremap <space> za
vnoremap <space> zf

" theme
colorscheme kolor
set bg=dark

" NERDTree
execute pathogen#infect()
au VimEnter *  NERDTree "automatic open NERDtree when open vim
au VimEnter * wincmd p "move cursor to file
"let NERDTreeShowHidden=1 "show hidden file

" -----NERD FONT-----
set guifont=Ubuntu\ Mono\ Nerd\ Font\ 11

" -----vim-devicons-----
set encoding=UTF-8

" -----lightline-----
set laststatus=2
if !has('gui_running')
    set t_Co=256
endif
set noshowmode
let g:lightline = {
       \ 'colorscheme': 'wombat',
       \ 'active': {
       \   'left': [ [ 'mode', 'paste' ],
       \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
       \ },
       \ 'component': {
       \   'filename': '%F'
       \ },
       \ 'component_function': {
       \   'gitbranch': 'gitbranch#name'
       \ },
       \ }


" exuberant-ctags
set tags=tags;
set autochdir

" change mapleader from \ to ,
let mapleader=","

" call plug#begin('~/.vim/bundle')
" Plug 'preservim/nerdcommenter'
" call plug#end()

" nerdcommenter
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" auto-complete
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap < <><Esc>i
inoremap { {}<Esc>i
inoremap ' ''<Esc>i
inoremap " ""<Esc>i
inoremap { {<CR>}<Esc>O

" vim-gitgutter
set signcolumn=yes
highlight SignColumn ctermbg=NONE
highlight SignColumn guibg=darkgrey
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1
set updatetime=100
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hp <Plug>(GitGutterPreviewHunk)
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)

" git-blame
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>

" fzf settings
" This is the default extra key bindings
let g:fzf_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
let g:fzf_layout = { 'window' : {'width': 0.8, 'height': 0.7 } }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
            \ { 'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'


" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1

" vimspector
" ~/.vim/plugged/vimspector/gadgets/macos/
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB' ]
let g:vimspector_enable_mappings='VISUAL_STUDIO'

" ---------------------- vim-plug-------------------------
call plug#begin('~/.vim/plugged')
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'puremourning/vimspector'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'zivyangll/git-blame.vim'
" plugin for golang
Plug 'fatih/vim-go', {'tag': '*' }
Plug 'dgryski/vim-godef'
Plug 'yaegassy/coc-ruff', {'do': 'yarn install --frozen-lockfile'}
call plug#end()
