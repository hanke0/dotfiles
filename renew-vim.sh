#! /bin/sh

cd ~ && mkdir ~/tmp_111
git clone  https://github.com/ko-han/.vim.git ~/tmp_111 || { echo "command failed"; exit 1; }
rm -rf ~/tmp_111/.git  || { echo "command failed"; exit 1; }
mv -f ~/tmp_111/* ~/  || { echo "command failed"; exit 1; }
chmod +x renew-vim.sh || { echo "command failed"; exit 1; }
rm -rf tmp_111 || { echo "command failed"; exit 1; }
echo "Great, All Things Hava Done, Enjoy It!"
