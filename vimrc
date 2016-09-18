"更方便的编辑：
set backspace=indent,eol,start whichwrap+=<,>,[,]
set ru
set whichwrap=b,s,<,>,[,]
set ambiwidth=double
set nocompatible
"set spell
set selection=inclusive
set clipboard+=unnamed  " Vim 的默认寄存器和系统剪贴板共享

"更方便的显示：
if has("gui_running")
  set encoding=utf-8
  set fileencodings=utf-8,chinese,latin-1
if has("win32")
  set fileencoding=chinese
else
  set fileencoding=utf-8
endif
let &termencoding=&encoding
"解决菜单乱码
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
"解决consle输出乱码
language messages zh_CN.utf-8
endif
set splitbelow
set splitright
set nu
"set relativenumber
syntax on
set hlsearch
"set cursorline  "突出显示当前行"
"set cursorcolumn  "突出显示当前列"
set wrap
set t_ti= t_te=

"增加功能：
filetype plugin indent on
set showmatch
set mouse=a  "启用鼠标"
set clipboard+=unnamed  "Vim的默认寄存器和系统剪贴板共享

"格式化：
set autoindent
set smartindent
set expandtab
set smarttab
set tabstop=4
set nobomb
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936
set encoding=utf-8

"主题配置"
if has('gui_running')
  set background=dark
  colorscheme solarized
  set guifont=Microsoft\ YaHei:h12:cANSI
else
  colorscheme Tomorrow-Night
endif

if has('win32')
  set renderoptions=type:directx
endif

"Function Start  ------------------------------------------------------------------  Function Start
"按F5运行python"
map <F5> :w<CR> :call RunPython()<CR>
function RunPython()
  let mp = &makeprg
  let ef = &errorformat
  let exeFile = expand("%:t")
  setlocal makeprg=python\ -u
  set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
  silent make %
  copen
  let &makeprg = mp
  let &errorformat = ef
endfunction

" Remove trailing whitespace when writing a buffer, but not for diff files.
function! RemoveTrailingWhitespace()
    if &ft != "diff"
        let b:curcol = col(".")
        let b:curline = line(".")
        silent! %s/\s\+$//
        silent! %s/\(\s*\n\)\+\%$//
        call cursor(b:curline, b:curcol)
    endif
endfunction
autocmd BufWritePre * call RemoveTrailingWhitespace()
"Function END  ------------------------------------------------------------------  Function END

"Vudle Start  ------------------------------------------------------------------  Vudle Start
filetype off
if has('win32')
  set rtp+=$VIM/vimfiles/bundle/Vundle
  call vundle#begin('$VIM/vimfiles/bundle')
else
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
endif

"插件开始"
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
map <F2> :NERDTreeToggle<CR>
let NERDTreeIgnore=['.idea', '.vscode', 'node_modules', '*.pyc','\~$', '\.pyc$', '\.swp$']
let NERDTreeBookmarksFile = $VIM . '/NERDTreeBookmarks'
let NERDTreeMinimalUI = 1
let NERDTreeBookmarksSort = 1
let NERDTreeShowLineNumbers = 0
let NERDTreeShowBookmarks = 1
let g:NERDTreeWinPos = 'right'
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"窗口大小"
let NERDTreeWinSize=25

Plugin 'Yggdroot/indentLine'
let g:indentLine_char='┆'
let g:indentLine_enabled = 1

Plugin 'tell-k/vim-autopep8'
autocmd FileType python map <buffer> <F8> :call Autopep8()<CR>
let g:autopep8_disable_show_diff=1

Plugin 'jiangmiao/auto-pairs'  "括号自动补全"

Plugin 'kien/rainbow_parentheses.vim'
"rainbow_parentheses
let g:rbpt_colorpairs = [ ['brown', 'RoyalBlue3'], ['Darkblue', 'SeaGreen3'], ['darkgray', 'DarkOrchid3'], ['darkgreen', 'firebrick3'],['darkcyan', 'RoyalBlue3'],['darkred', 'SeaGreen3'],['darkmagenta', 'DarkOrchid3'],['brown', 'firebrick3'],['gray', 'RoyalBlue3'],['black',       'SeaGreen3'],['darkmagenta', 'DarkOrchid3'],['Darkblue',  'firebrick3'],['darkgreen', 'RoyalBlue3'],['darkcyan', 'SeaGreen3'],['darkred', 'DarkOrchid3'],['red', 'firebrick3']]
let g:rbpt_max = 16
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

Plugin 'ctrlpvim/ctrlp.vim'  "快速查找文件Ctrl+P"

Bundle 'bling/vim-airline'
set laststatus=2
"插件结束"
call vundle#end()
filetype plugin indent on
"Vudle End  ------------------------------------------------------------------  Vudle End
