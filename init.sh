#! /bin/sh

cd ~ && mkdir ~/tmp_111
git clone --no-checkout https://github.com/hanke-tunner/.vim.git ~/tmp_111
mv ~/tmp_111/.git ~ && rmdir tmp_111
git reset --hard HEAD
git pull
echo "Done!"
