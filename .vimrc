"
"           / /_  ____ _____     _   __(_)___ ___
"          / __ \/ __ `/ __ \   | | / / / __ `__ \
"         / / / / /_/ / / / /   | |/ / / / / / / /
"        /_/ /_/\__,_/_/ /_/    |___/_/_/ /_/ /_/
"
"


" -- General Settings ----------------------------------------------------------
set nocompatible    " disable vi compatible
syntax enable       " code syntax highlight
filetype on         " detect file type
filetype plugin on  " load plugin base on file type
filetype indent on  " use different indent in different file type

" indent
set expandtab       " don't use tab
set tabstop=4       " tab expand to 4 space
set shiftwidth=4    "
set softtabstop=4   "

set backspace=2             " use backspace delete more character
set whichwrap=b,s,<,>,[,]   " cursor could move to any line
set ambiwidth=double        " display non-ascii characters
set autochdir               " change to directory where file stores
set selection=inclusive     " include cursor character
set nobackup                " disable backup
set noswapfile              " disable swap file
set showmode                " show current mode
set ignorecase              " case insensitive search
set smartcase               " case sensitive if has upper case in pattern
set winaltkeys=no           " disable alt in windows
set nobomb                  " disable bom
set fileencodings=utf-8     "
set encoding=utf-8          "
set completeopt=preview,menu
set clipboard+=unnamed      " share clipboard

set t_Co=256                " 256
set splitright              " new split window on right
set nohlsearch              " don't highlight search
set colorcolumn=80          "
set nowrap                  " no wrap
set shortmess=a             "
set cmdheight=2             "
set showcmd                 "
set showmatch               "
set nofoldenable

highlight WhiteSpaceEOL ctermbg=darkgreen guibg=lightgreen " line end space
match WhiteSpaceEOL /\s$/

" config
set autoread                " auto detect outer changes
autocmd BufWritePost $MYVIMRC source $MYVIMRC   " auto load config changes

"some stuff to get the mouse going in term
"set mouse=a

" running environment detect
if(has("win32") || has("win64") || has("win95") || has("win16"))
    let g:isWin = 1
else
    let g:isWin = 0
endif

if has("gui_running")
    let g:isGUI = 1
else
    let g:isGUI = 0
endif

if &filetype == 'py'||&filetype == 'python'
    set foldmethod=indent
    set foldlevel=99
else
    set foldmethod=syntax
    set foldlevel=99
endif


"-- Display -------------------------------------------------------------------
if g:isGUI
    set guifont=Source\ Code\ Pro:h12
    set guioptions-=m
    set guioptions-=T
endif
if g:isWin
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
endif

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

set laststatus=2
let g:currentmode={
      \ 'n'  : 'NORMAL ',
      \ 'no' : 'N·Operator Pending ',
      \ 'v'  : 'VISUAL ',
      \ 'V'  : 'V·Line ',
      \ 'x22' : 'V·Block ',
      \ 's'  : 'Select ',
      \ 'S'  : 'S·Line ',
      \ 'x19' : 'S·Block ',
      \ 'i'  : 'INSERT ',
      \ 'R'  : 'REPLACE ',
      \ 'Rv' : 'V·Replace ',
      \ 'c'  : 'COMMAND ',
      \ 'cv' : 'Vim Ex ',
      \ 'ce' : 'Ex ',
      \ 'r'  : 'PORMAT ',
      \ 'rm' : 'MORE ',
      \ 'r?' : 'CONFIRM ',
      \ '!'  : 'SHELL ',
      \ 't'  : 'TERMIANL '
      \}
function! PasteForStatusline()
    let paste_status = &paste
    if paste_status == 1
        return "[PASTE] "
    else
        return ""
    endif
endfunction
set statusline+=%1*\ %{g:currentmode[mode()]}   " Current mode
set statusline+=%{PasteForStatusline()}       " paste flag
set statusline+=%2*\ %F%m%r%h%w
set statusline+=\ %3*%=
set statusline+=[FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]
"[ASCII=\%03.3b]\ [HEX=\%02.2B]

hi User1 ctermbg=red    ctermfg=white
hi User2 ctermbg=black  ctermfg=white
hi User3 ctermbg=black  ctermfg=green

" -- Key Bindings -------------------------------------------------------------
let mapleader = ","

nnoremap <leader>W :w !sudo tee % > /dev/null<CR>  " Save a file as root (,W)

set pastetoggle=<F6>    " enable/disable paste-mode

nnoremap <F2> :set number! number?<CR>     " relative line number
nnoremap <F3> :set wrap! wrap?<CR>

"strip all trailing whitespace in the current file
nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<CR>

nnoremap <leader><Tab> <C-w><C-w>  " change splits
nnoremap <leader>h <C-w>h     " left
nnoremap <leader>j <C-w>j     " down
nnoremap <leader>k <C-w>k     " up
nnoremap <leader>l <C-w>l     " right
nnoremap <leader>z za         " fold, unfold
nnoremap <leader>x :x<CR>     " save and exit
nnoremap <leader>q :q!<CR>    " exit

inoremap <C-h> <ESC>I         " cursor move to line start
inoremap <C-j> <ESC><Down>I   " cursor move to next line start
inoremap <C-l> <ESC>A         " cursor move to line end
inoremap <C-k> <ESC><Up>A     " cursor move to previous line end

vnoremap <C-c> "+y        " use CTRL+C to copy on v-mode
vnoremap <C-v> "+gP       " use CTRL+V to paste on v-mode
vnoremap <leader>z zf     " fold selected code
