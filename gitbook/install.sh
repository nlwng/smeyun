安装nvm
cd ~
mkdir .nvm
cd .nvm
git clone https://github.com/creationix/nvm
source ~/.nvm/nvm/nvm.sh

安装node
nvm install node

安装npm
git clone --recursive git://github.com/isaacs/npm.git
cd npm
node cli.js install npm -g

安装gitbook
npm install gitbook-cli -g

安装python2.7
sudo apt-get install python2.7-dev
wget https://bootstrap.pypa.io/ez_setup.py
sudo python2 ez_setup.py install
sudo easy_install-2.7 pip

安装calibre
http://www.calibre-ebook.com/download_linux
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"

#使用gitbook
mkdir -p ~/gitbookworkspace/demo
cd ~/gitbookworkspace/demo
gitbook init

#可以生成网页
gitbook build
#可以生成pdf文件
gitbook pdf ~/gitbookworkspace/demo ~/gitbookworkspace/demo.pdf
