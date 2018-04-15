"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
"
"           / /_  ____ _____     _   __(_)___ ___ 
"          / __ \/ __ `/ __ \   | | / / / __ `__ \
"         / / / / /_/ / / / /   | |/ / / / / / / /
"        /_/ /_/\__,_/_/ /_/    |___/_/_/ /_/ /_/ 
"
"
" Q: How to use it?
" A: curl -fsSL https://raw.githubusercontent.com/ko-han/han-vim/master/han-vim.sh | sh
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""





"""""""""""""""""""""""""""""""""""""""""
"通用
"""""""""""""""""""""""""""""""""""""""""
"取消vi兼容模式
set nocompatible
" 开启语法高亮功能
syntax enable
" 允许用指定语法高亮配色方案替换默认方案
syntax on

"插件管理
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()


"文件自动检测外部更改
set autoread
"检测文件格式
filetype on 
filetype plugin on 
filetype indent on 
"backspace 可以删除更多字符
set backspace=indent,eol,start
"打开 VIM 的状态栏标尺
set ru
"光标可以移动到上一行
set whichwrap=b,s,<,>,[,]
"防止特殊符号无法正常显示
set ambiwidth=double
set autochdir
"打开拼写检查
"set spell
set selection=inclusive
"Vim 的默认寄存器和系统剪贴板共享
set clipboard+=unnamed
"80字符限制线"
"set colorcolumn=80
"不显示一些东西如乌干达儿童提示
set shortmess=a
set cmdheight=2
"取消备份。 视情况自己改
set nobackup
"关闭交换文件
set noswapfile
set ignorecase
"行号
set number
set relativenumber
"显示当前输入的命令
set showcmd
"输入时显示相对应的括号
set showmatch
"ALT不映射到菜单栏
set winaltkeys=no
" 让配置变更立即生效
autocmd BufWritePost $MYVIMRC source $MYVIMRC
set rtp+=~/.vim
"运行环境判断
if(has("win32") || has("win64") || has("win95") || has("win16"))
    let g:iswindows = 1
else
    let g:iswindows = 0
endif

if has("gui_running")
    let g:isGUI = 1
else
    let g:isGUI = 0
endif

"""""""""""""""""""""""""""""""""""""""""
"显示设置
"""""""""""""""""""""""""""""""""""""""""
set background=light
colorscheme solarized
if g:isGUI
    set encoding=utf-8
    set guifont=Source\ Code\ Pro:h12
    " 禁止显示菜单和工具条
    set guioptions-=m
    set guioptions-=T
    "启用鼠标"
    set mouse=a
endif
if g:iswindows
    "解决菜单乱码
    source $VIMRUNTIME/delmenu.vim
    "解决consle输出乱码
    source $VIMRUNTIME/menu.vim
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
endif

"新分割窗口在下边
set splitbelow
"新分割窗口在右边
set splitright
"行号变成相对
"set relativenumber
"高亮搜索词
set hlsearch
"突出显示当前行
set cursorline
"突出显示当前列
"set cursorcolumn
"折行
set nowrap
"防止错误整行标红导致看不清
highlight clear SpellBad
highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline

"状态栏
set laststatus=2
set statusline=
set statusline+=%1*[%F%m%r%h%w]
set statusline+=\ \ \ \ %1*[FORMAT=%2*%{&ff}:%{&fenc!=''?&fenc:&enc}%1*]
set statusline+=\ %1*[TYPE=%2*%Y%1*]
set statusline+=\ [COL=%2*%03v%1*]
set statusline+=\ [ROW=%2*%03l%1*/%3*%L(%p%%)%1*]

"""""""""""""""""""""""""""""""""""""""""
"格式化
"""""""""""""""""""""""""""""""""""""""""
" 将制表符扩展为空格
set expandtab
" 设置编辑时制表符占用空格数
set tabstop=4
" 设置格式化时制表符占用空格数
set shiftwidth=4
" 让 vim 把连续数量的空格视为一个制表符
set softtabstop=4

autocmd FileType python setlocal expandtab sta sw=4 sts=4
autocmd FileType ruby,javascript,html,css,xml set ts=2 sw=2 softtabstop=2 expandtab ai

set nobomb
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936
set encoding=utf-8
let &termencoding=&encoding

"""""""""""""""""""""""""""""""""""""""""
"插件
"""""""""""""""""""""""""""""""""""""""""
"nerdtree

"vim-airline
let g:airline_theme='solarized'

"ctrlpvim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
    \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz|pyc)$',
    \ }
if g:iswindows
    let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'
else
    let g:ctrlp_user_command = 'find %s -type f'
endif
"""""""""""""""""""""""""""""""""""""""""
"函数
"""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""
"按键设置
"""""""""""""""""""""""""""""""""""""""""
let mapleader=","

nnoremap <F2> :set relativenumber! relativenumber?<CR>
nnoremap <F3> :exec exists('syntax_on') ? 'syn off' : 'syn on'<CR>
nnoremap <F4> :set wrap! wrap?<CR>
"粘贴模式快捷键
set pastetoggle=<F5>
map <C-n> :NERDTreeToggle<CR>

"strip all trailing whitespace in the current file
nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<CR>

"选中状态下 Ctrl+c 复制
vmap <C-c> "+y
"选中状态下 Ctrl+v 粘贴
vmap <C-v> "+gP

" 方便切换 splits
nmap <C-Tab> <C-w><C-w>
nmap <leader>h <C-w>h
nmap <leader>l <C-w>l
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k

" press space to fold/unfold code
if &filetype == 'py'||&filetype == 'python'
    set foldmethod=indent
    set foldlevel=99
else
    set foldmethod=syntax
    set foldlevel=99
endif
" 启动 vim 时关闭折叠代码
set nofoldenable
nnoremap <space> za
vnoremap <space> zf
