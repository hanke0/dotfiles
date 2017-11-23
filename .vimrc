"    Q: How to use it?
"    A: RUN renew-vim.sh to update

"    # Plugin Options
"    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

"按键设置{
    let mapleader=","

    nnoremap <F2> :set relativenumber! relativenumber?<CR>
    nnoremap <F3> :exec exists('syntax_on') ? 'syn off' : 'syn on'<CR>
    nnoremap <F4> :set wrap! wrap?<CR>
    " Ctril + B 一键保存、编译、连接存并运行
    map <c-B> :call Run()<CR>
    imap <c-B> <ESC>:call Run()<CR>
    " Ctrl + F9 一键保存并编译
    map <c-F9> :call Compile()<CR>
    imap <c-F9> <ESC>:call Compile()<CR>
    " Ctrl + F10 一键保存并连接
    map <c-F10> :call Link()<CR>
    imap <c-F10> <ESC>:call Link()<CR>
    "粘贴模式快捷键
    set pastetoggle=<F5>

    "保存并删除行尾空格
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

"}


"基本设置{
    "取消vi兼容模式
    set nocompatible
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
    "number 行号
    set nu
    "ALT不映射到菜单栏
    set winaltkeys=no
    " 开启语法高亮功能
    syntax enable
    " 允许用指定语法高亮配色方案替换默认方案
    syntax on
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
"}


"显示设置{
    if g:isGUI
        set encoding=utf-8
        set background=dark
        colorscheme solarized
        set guifont=DejaVu\ Sans\ Mono:h12
        set encoding=utf-8
        let $LANG = 'en_US.UTF-8'
        " 禁止光标闪烁
        set gcr=a:block-blinkon0
        " 禁止显示滚动条
        set guioptions-=l
        set guioptions-=L
        set guioptions-=r
        set guioptions-=R
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

    let &termencoding=&encoding
    "新分割窗口在下边
    set splitbelow
    "新分割窗口在右边
    set splitright
    "行号变成相对
    "set relativenumber
    "高亮搜索词
    "set hlsearch
    "突出显示当前行
    "set cursorline
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
"}


"格式化{
    " 自适应不同语言的智能缩进
    filetype indent on
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
"}


"函数功能{
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


    "GCC编译运行相关
    let s:LastShellReturn_C = 0
    let s:LastShellReturn_L = 0
    let s:ShowWarning = 1
    let s:Obj_Extension = '.o'
    let s:Exe_Extension = '.exe'
    let s:Sou_Error = 0

    let s:windows_CFlags = 'gcc\ -fexec-charset=gbk\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'
    let s:linux_CFlags = 'gcc\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'

    let s:windows_CPPFlags = 'g++\ -fexec-charset=gbk\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'
    let s:linux_CPPFlags = 'g++\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'

    func! Compile()
        exe ":ccl"
        exe ":update"
        if expand("%:e") == "c" || expand("%:e") == "cpp" || expand("%:e") == "cxx"
            let s:Sou_Error = 0
            let s:LastShellReturn_C = 0
            let Sou = expand("%:p")
            let Obj = expand("%:p:r").s:Obj_Extension
            let Obj_Name = expand("%:p:t:r").s:Obj_Extension
            let v:statusmsg = ''
            if !filereadable(Obj) || (filereadable(Obj) && (getftime(Obj) < getftime(Sou)))
                redraw!
                if expand("%:e") == "c"
                    if g:iswindows
                        exe ":setlocal makeprg=".s:windows_CFlags
                    else
                        exe ":setlocal makeprg=".s:linux_CFlags
                    endif
                    echohl WarningMsg | echo " compiling..."
                    silent make
                elseif expand("%:e") == "cpp" || expand("%:e") == "cxx"
                    if g:iswindows
                        exe ":setlocal makeprg=".s:windows_CPPFlags
                    else
                        exe ":setlocal makeprg=".s:linux_CPPFlags
                    endif
                    echohl WarningMsg | echo " compiling..."
                    silent make
                endif
                redraw!
                if v:shell_error != 0
                    let s:LastShellReturn_C = v:shell_error
                endif
                if g:iswindows
                    if s:LastShellReturn_C != 0
                        exe ":bo cope"
                        echohl WarningMsg | echo " compilation failed"
                    else
                        if s:ShowWarning
                            exe ":bo cw"
                        endif
                        echohl WarningMsg | echo " compilation successful"
                    endif
                else
                    if empty(v:statusmsg)
                        echohl WarningMsg | echo " compilation successful"
                    else
                        exe ":bo cope"
                    endif
                endif
            else
                echohl WarningMsg | echo ""Obj_Name"is up to date"
            endif
        else
            let s:Sou_Error = 1
            echohl WarningMsg | echo " please choose the correct source file"
        endif
        exe ":setlocal makeprg=make"
    endfunc

    func! Link()
        call Compile()
        if s:Sou_Error || s:LastShellReturn_C != 0
            return
        endif
        let s:LastShellReturn_L = 0
        let Sou = expand("%:p")
        let Obj = expand("%:p:r").s:Obj_Extension
        if g:iswindows
            let Exe = expand("%:p:r").s:Exe_Extension
            let Exe_Name = expand("%:p:t:r").s:Exe_Extension
        else
            let Exe = expand("%:p:r")
            let Exe_Name = expand("%:p:t:r")
        endif
        let v:statusmsg = ''
        if filereadable(Obj) && (getftime(Obj) >= getftime(Sou))
            redraw!
            if !executable(Exe) || (executable(Exe) && getftime(Exe) < getftime(Obj))
                if expand("%:e") == "c"
                    setlocal makeprg=gcc\ -o\ %<\ %<.o
                    echohl WarningMsg | echo " linking..."
                    silent make
                elseif expand("%:e") == "cpp" || expand("%:e") == "cxx"
                    setlocal makeprg=g++\ -o\ %<\ %<.o
                    echohl WarningMsg | echo " linking..."
                    silent make
                endif
                redraw!
                if v:shell_error != 0
                    let s:LastShellReturn_L = v:shell_error
                endif
                if g:iswindows
                    if s:LastShellReturn_L != 0
                        exe ":bo cope"
                        echohl WarningMsg | echo " linking failed"
                    else
                        if s:ShowWarning
                            exe ":bo cw"
                        endif
                        echohl WarningMsg | echo " linking successful"
                    endif
                else
                    if empty(v:statusmsg)
                        echohl WarningMsg | echo " linking successful"
                    else
                        exe ":bo cope"
                    endif
                endif
            else
                echohl WarningMsg | echo ""Exe_Name"is up to date"
            endif
        endif
        setlocal makeprg=make
    endfunc

    func! Run()
        let s:ShowWarning = 0
        call Link()
        let s:ShowWarning = 1
        if s:Sou_Error || s:LastShellReturn_C != 0 || s:LastShellReturn_L != 0
            return
        endif
        let Sou = expand("%:p")
        let Obj = expand("%:p:r").s:Obj_Extension
        if g:iswindows
            let Exe = expand("%:p:r").s:Exe_Extension
        else
            let Exe = expand("%:p:r")
        endif
        if executable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
            redraw!
            echohl WarningMsg | echo " running..."
            if g:iswindows
                exe ":!%<.exe"
            else
                if g:isGUI
                    exe ":!gnome-terminal -e ./%<"
                else
                    exe ":!./%<"
                endif
            endif
            redraw!
            echohl WarningMsg | echo " running finish"
        endif
    endfunc
"}
