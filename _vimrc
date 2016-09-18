" 分割出来的窗口位于当前窗口下边/右边 
set splitbelow
set splitright
"编码设置"
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936 
set encoding=utf-8 
set langmenu=zh_CN 
let $LANG = 'en_US.UTF-8'
"开启directX"
set renderoptions=type:directx
"主题配置"
"colorscheme molokai
"去掉vi的一致性"
set nocompatible
"设置命令缓冲区可见
set laststatus=2
"关闭自动保存
set nobackup
"关闭交换文件
set noswapfile
"设置快速搜索
set incsearch
"设置最多记忆命令行数1000行
set history=1000
"设置括号匹配
set showmatch
"开启行号"
set nu
"开启相对行号
set relativenumber
"启用鼠标
set mouse=a
"Vim的默认寄存器和系统剪贴板共享
set clipboard+=unnamed
" 将Tab自动转化成空格
set expandtab
" 设置tab键的宽度
set tabstop=2
"语法高亮
syntax on
"高亮搜索项"
set hlsearch
"突出显示当前行"
"set cursorline
"突出显示当前列" 
"set cursorcolumn
"-------------------------------------------------------------------------------------------"
"按F5运行python"
map <F5> :Autopep8<CR> :w<CR> :call RunPython()<CR>
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
"-------------------------------------------------------------------------------------------"
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
"插件开始"
Plugin 'Lokaltog/vim-powerline'
Plugin 'scrooloose/nerdtree'
Plugin 'Yggdroot/indentLine'
Plugin 'jiangmiao/auto-pairs'
Plugin 'tell-k/vim-autopep8'
Plugin 'scrooloose/nerdcommenter'
Plugin 'kien/rainbow_parentheses.vim'
"插件结束"
call vundle#end()
filetype plugin indent on
"-------------------------------------------------------------------------------------------"
"NerdTree {
"F2开启和关闭树"
map <F2> :NERDTreeToggle<CR>
let NERDTreeChDirMode=1
"显示书签"
let NERDTreeShowBookmarks=1
"设置忽略文件类型"
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']
"窗口大小"
let NERDTreeWinSize=25
"}

"autopep8{
"缩进指示线"
let g:indentLine_char='┆'
let g:indentLine_enabled = 1
 
"autopep8设置"
let g:autopep8_disable_show_diff=1
"}

"nerdcommenter&pairs{
let mapleader=','
map <F4> <leader>ci <CR>
"}

"rainbow_parentheses{
let g:rbpt_colorpairs = [ ['brown', 'RoyalBlue3'], ['Darkblue', 'SeaGreen3'], ['darkgray', 'DarkOrchid3'], ['darkgreen', 'firebrick3'],['darkcyan', 'RoyalBlue3'],['darkred', 'SeaGreen3'],['darkmagenta', 'DarkOrchid3'],['brown', 'firebrick3'],['gray', 'RoyalBlue3'],['black',       'SeaGreen3'],['darkmagenta', 'DarkOrchid3'],['Darkblue',  'firebrick3'],['darkgreen', 'RoyalBlue3'],['darkcyan', 'SeaGreen3'],['darkred', 'DarkOrchid3'],['red', 'firebrick3']]
let g:rbpt_max = 16
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
"}