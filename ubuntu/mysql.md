sudo apt-get install mysql-server
sudo apt isntall mysql-client
sudo apt install libmysqlclient-dev

mysql -u root -p        
mysql> use mysql; 
mysql> select 'host' from user where user='root';
mysql> update user set host = '%' where user = 'root';
mysql> flush privileges;
