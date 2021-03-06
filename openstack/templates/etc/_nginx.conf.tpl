user root;
worker_processes auto;
pid /run/nginx.pid;

env SERVER_NAME;
env UWSGI_PORT;

events {
        worker_connections 768;
        # multi_accept on;
}

http {
        perl_set $server_name 'sub { return $ENV{"SERVER_NAME"}; }';
        perl_set $uwsgi_port 'sub { return $ENV{"UWSGI_PORT"}; }';

        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;
        gzip_disable "msie6";

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # Virtual Host Configs
        ##

        server {
          listen 80;
          server_name $server_name;
          location / {
            root /var/www/customersite1;
            uwsgi_pass 127.0.0.1:$uwsgi_port;
            include uwsgi_params;
          }
        }

        # include /etc/nginx/conf.d/*.conf;
        # include /etc/nginx/sites-enabled/*;
}
