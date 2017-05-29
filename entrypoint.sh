# Create log dirs and files
mkdir -p $( dirname $(cat /etc/supervisor/conf.d/supervisord.conf  | grep logfile= | grep "\.log" | sed s/.*logfile=// ) )
touch $( cat /etc/supervisor/conf.d/supervisord.conf  | grep logfile= | grep "\.log" | sed s/.*logfile=// )

# Then run supervisord
/usr/bin/supervisord