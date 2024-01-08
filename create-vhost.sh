#!/bin/bash
while getopts s:h:d flag
do
case "${flag}" in
                s) sitename=${OPTARG}
                        ;;
                h) host=${OPTARG}
                         ;;
                d) createdir=1
                        ;;
                *) echo "Invalid option: -$flag" ;;
        esac
done
# Create and configure folder in `/var/www` if option if option selected
if [[ $createdir -eq 1 ]]
then
  mkdir /var/www/$sitename
  echo "Folder /var/www/$sitename created"
  # Creating dummy landing page
  cp default-index.html /var/www/$sitename/index.html
  echo "Intitialized with index page"

  # Changing owner and permission of the folder
  chown $SUDO_USER:$SUDO_USER /var/www/$sitename
  chmod 755 /var/www/$sitename
  echo "Modified permissions and owner"
fi
# Creating configuration files
cd /etc/apache2/sites-available/
cp default-vhost.conf $sitename.conf
sed -i "s/example.local/$sitename/g" $sitename.conf
sed -i "s/127.0.0.x/$host/g" $sitename.conf
echo "Configuration files created"

# Configuring hosts file
sed -i "0,/# The following lines are desirable for IPv6 capable hosts/s/^# The following lines are desirable.*/$host       $sitename\n&/" /etc/hosts
echo "Added entry in hosts file"

# Enabling virtual host and restarting the server
a2ensite $sitename.conf
systemctl reload apache2
echo "Restarted apache"
echo "All done! Visit your newly created virtual host at https://$sitename"
