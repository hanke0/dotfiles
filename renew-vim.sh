#! /bin/bash
set -e

cd ~ && mkdir ~/tmp_111
git clone  https://github.com/ko-han/.vim.git ~/tmp_111
rm -rf ~/tmp_111/.git
mv -f ~/tmp_111/* ~/
chmod +x renew-vim.sh
rm -rf tmp_111
echo "Great, All Things Hava Done, Enjoy It!"
