
" Startup {{{
filetype indent plugin on

" vim 文件折叠方式为 marker
augroup ft_vim
    au!
    au FileType vim setlocal foldmethod=marker
augroup END
" }}}
"-------------------------------------------------------------------------------------------------------------------------------

" General {{{
set laststatus=2	" 设置命令缓冲区可见
set nobackup		" 关闭自动保存
set noswapfile		" 关闭交换文件
set incsearch		" 设置快速搜索
set history=1000	" 设置最多记忆命令行数1000行
set showmatch		" 设置括号匹配
set vb t_vb=		" 去掉声音提示
set compatible  "关闭兼容VI模式
set relativenumber  " 开启相对行号
set backspace=2 " 设置退格键可用
set mouse=a " 启用鼠标
set backspace=indent,eol,start whichwrap+=<,>,[,]		" 设置<BS>键模式
set clipboard+=unnamed  " Vim 的默认寄存器和系统剪贴板共享
set winaltkeys=no  " 设置 alt 键不映射到菜单栏
" }}}
"-------------------------------------------------------------------------------------------------------------------------------

" Format {{{
set ai! " 设置自动缩进
set cindent shiftwidth=2 " 自动缩进4空格
set autoindent " 自动对齐
set smartindent " 智能自动缩进
set smartindent "设置智能缩进
set expandtab   " 将Tab自动转化成空格 [需要输入真正的Tab键时，使用 Ctrl+V + Tab]
set softtabstop=4 "软tab宽度
set tabstop=2 " 设置tab键的宽度
syntax on  "语法高亮
" }}}
"-------------------------------------------------------------------------------------------------------------------------------

" GUI {{{
colorscheme monokai "sublime的配色方案
set shortmess=atI "去掉欢迎界面
set cursorline
set hlsearch
set number "显示行号
" 窗口大小
set lines=35 columns=140
" 分割出来的窗口位于当前窗口下边/右边
set splitbelow
set splitright
"不显示工具/菜单栏
set guioptions-=T
set guioptions-=m
set guioptions-=L
set guioptions-=r
set guioptions-=b
" 使用内置 tab 样式而不是 gui
set guioptions-=e
set nolist
" set listchars=tab:▶\ ,eol:¬,trail:·,extends:>,precedes:<
" }}}
"-------------------------------------------------------------------------------------------------------------------------------

" Lang & Encoding{{{
source $VIMRUNTIME/delmenu.vim  
source $VIMRUNTIME/menu.vim
"vim支持打开的文件编码  
set fileencodings=utf-8,ucs-bom,shift-jis,latin1,big5,gb18030,gbk,gb2312,cp936  "文件 UTF-8 编码  
" 解决显示界面乱码  
set fileencoding=utf-8  
set encoding=utf-8      "vim 内部编码  
set termencoding=utf-8  
"处理菜单及右键菜单乱码  
set langmenu=zh_CN
let $LANG = 'zh_CN'
set helplang=cn
" }}}
"-------------------------------------------------------------------------------------------------------------------------------

" Function {{{
function! RemoveTrailingWhitespace()  " Remove trailing whitespace when writing a buffer, but not for diff files.
    if &ft != "diff"
        let b:curcol = col(".")
        let b:curline = line(".")
        silent! %s/\s\+$//
        silent! %s/\(\s*\n\)\+\%$//
        call cursor(b:curline, b:curcol)
    endif
endfunction
autocmd BufWritePre * call RemoveTrailingWhitespace()

func Maximize_Window()	" 自动最大化窗口
  silent !wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
endfunc

func! CompileRunGcc()	" 自动编译运行程序 (gcc)
exec "w"
exec "make"
exec "!./%<"
endfunc

func! GdbCode()		" 自动编译调试 (gdb)
exec "w"
exec "!gcc -Wall -lm -g % -o %<"
exec "!gdb ./%<"
endfunc

func! RunPython()
exec "w"
exec "!python %"
endfunc

func! CompileRunHaskell()
exec "w"
exec "!ghc % -o %<"
endfunc
" }}}
"-------------------------------------------------------------------------------------------------------------------------------
" key map {{{
" F5为自动编译运行
if &filetype == 'C'
	map <F5> :call CompileRunGcc()<CR>
elseif &filetype == 'Python'
	map <F5> :call RunPython()<CR>
elseif &filetype == 'haskell'
	map <F5> :call CompileRunHaskell()<CR>
endif
" F6为自动调试
map <F6> :call GdbCode()<CR>
" 空格控制折叠
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
" F3插入模板
map <F3> : LoadTemplate <CR>
" Ctrl+N 键下个错误
map <C-N> : cn <CR>
" Ctrl+P 键上个错误
map <C-P> : cp <CR>
"}}}




