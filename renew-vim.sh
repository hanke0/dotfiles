#! /bin/sh

cd ~ && mkdir ~/tmp_111
git clone  https://github.com/ko-han/.vim.git ~/tmp_111
rm -rf ~/tmp_111/.git
mv ~/tmp_111/* ~ && rmdir tmp_111
echo "Great, All Things Hava Done, Enjoy It!"
