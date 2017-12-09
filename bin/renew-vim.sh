#!/bin/bash

cd ~ && mkdir ~/tmp_han_vim_config
git clone  https://github.com/ko-han/.vim.git ~/tmp_han_vim_config
rm -rf ~/tmp_han_vim_config/.git
cp -r ~/tmp_111/*  ~/tmp_han_vim_config/.[^.]* ~/
chmod +x ~/bin/renew-vim.sh
rm -rf ~/tmp_han_vim_config
echo ""
echo "Great, All Things Hava Done, Enjoy It!"
