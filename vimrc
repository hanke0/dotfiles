"
"           / /_  ____ _____     _   __(_)___ ___
"          / __ \/ __ `/ __ \   | | / / / __ `__ \
"         / / / / /_/ / / / /   | |/ / / / / / / /
"        /_/ /_/\__,_/_/ /_/    |___/_/_/ /_/ /_/
"
"


"============================== 通用 ==============================
set nocompatible    "取消vi兼容模式
syntax enable   " 开启语法高亮功能
filetype on     "打开文件类型检测功能
filetype plugin on    "允许vim加载文件类型插件
filetype indent on    "允许vim为不同类型的文件定义不同的缩进格式

" tab
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab

set ai "Auto indent
set si "Smart indent

set backspace=2  "backspace 可以删除更多字符
set whichwrap=b,s,<,>,[,]   "光标可以移动到上一行
set ambiwidth=double    "防止特殊符号无法正常显示
set autochdir    "自动切换到文件所在文件夹
set selection=inclusive    "在选择文本时，光标所在位置也属于被选中的范围
set nobackup    "取消备份。 视情况自己改
set noswapfile    "关闭交换文件
set showmode "显示当前命令模式
set ignorecase    "设置默认进行大小写不敏感查找
set smartcase    "如果有一个大写字母，则切换到大小写敏感查找
set winaltkeys=no    "ALT不映射到菜单栏
set nobomb    "去掉 BOM
set fileencodings=utf-8
set encoding=utf-8

set autoread    "文件自动检测外部更改
autocmd BufWritePost $MYVIMRC source $MYVIMRC   "让配置变更立即生效

"some stuff to get the mouse going in term
set mouse=a
if !has("nvim")
    set ttymouse=xterm2
endif

set nofoldenable

"运行环境判断
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


"============================== 显示 ==============================
if g:isGUI
    set guifont=Source\ Code\ Pro:h12
    set guioptions-=m     "禁止显示菜单
    set guioptions-=T     "禁止显示工具条
endif
if g:isWin
    source $VIMRUNTIME/delmenu.vim     "解决菜单乱码
    "解决consle输出乱码
    source $VIMRUNTIME/menu.vim
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
endif

set t_Co=256
set splitright  "新分割窗口在右边
set hlsearch  "高亮搜索词
set cursorline  "突出显示当前行
set colorcolumn=99  "80字符限制线
set nowrap        "折行
set shortmess=a    "不显示一些东西如乌干达儿童提示
set cmdheight=2    "命令行（在状态行下）的高度，默认为1，这里是2

set showcmd     "显示当前输入的命令
set showmatch     "输入时显示相对应的括号

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500


"============================== 插件 ==============================
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'  "<leader>cu 取消注释 <leader>cc 注释
Plug 'vim-airline/vim-airline'

"nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
nnoremap <C-n> :NERDTreeToggle<CR>    "目录

call plug#end()


"============================== 快捷键 ==============================
let mapleader = ","

" :W sudo saves the file 
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

set pastetoggle=<F6>    "粘贴模式快捷键

nnoremap <F2> :set relativenumber! relativenumber?<CR>     "相对行号
nnoremap <F3> :exec exists('syntax_on') ? 'syn off' : 'syn on'<CR>   "代码高亮
nnoremap <F4> :set wrap! wrap?<CR>    "折行
nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<CR>    "strip all trailing whitespace in the current file
nnoremap <leader>W :w !sudo tee % > /dev/null<CR>  " Save a file as root (,W)
nnoremap <leader><Tab> <C-w><C-w>  " 方便切换 splits
nnoremap <leader>h <C-w>h     "左
nnoremap <leader>j <C-w>j     "下
nnoremap <leader>k <C-w>k     "上
nnoremap <leader>l <C-w>l     "右
nnoremap <leader>z za         "打开/关闭当前的折叠
nnoremap <leader>x :x<CR>     "保存退出
nnoremap <leader>q :q<CR>     "退出

inoremap <c-h> <ESC>I         "光标移当前行行首
inoremap <c-j> <ESC><Down>I   "光标移下一行行首
inoremap <c-k> <ESC><Up>A     "光标移上一行行尾
inoremap <c-l> <ESC>A         "光标移当前行行尾

vnoremap <C-c> "+y        "选中状态下 Ctrl+c 复制
vnoremap <C-v> "+gP       "选中状态下 Ctrl+v 粘贴
vnoremap <leader>z zf     "折叠选中文本
