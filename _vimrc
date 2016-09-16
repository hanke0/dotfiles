"主题配置"
let g:solarized_termcolors=256
colorscheme solarized
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