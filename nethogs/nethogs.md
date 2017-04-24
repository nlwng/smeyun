#install nethogs
sudo apt-get install build-essential
sudo apt-get install libncurses5-dev libpcap-dev
wget -c https://github.com/raboof/nethogs/archive/v0.8.1.tar.gz
tar xf v0.8.1.tar.gz
cd ./nethogs-0.8.1/
make && sudo make install


