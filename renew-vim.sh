#! /bin/bash

cd ~ && mkdir ~/tmp_111
git clone  https://github.com/ko-han/.vim.git ~/tmp_111
rm -rf ~/tmp_111/.git
cp -rf ~/tmp_111/*  ~/tmp_111/.[^.]* ~/ # include hide files (start with .)
chmod +x ~/bin/renew-vim.sh
rm -rf ~/tmp_111

echo "\nGreat, All Things Hava Done, Enjoy It!"
