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
