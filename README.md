# php7
dont forget to add ssh keys if your project is private
/var/www/.ssh

make sure that no webroot is pointing to var/www/ directly!



Complete new host
-----------------

Start php Container -> open shell
```
sudo -u www-data git clone -b master GITREPOSITORY .
sudo -u www-data composer install
sudo -u www-data ./init --env=Production --overwrite=n
```


