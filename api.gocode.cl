server {
    server_name api.gocode.cl;
    proxy_set_header  Host  $host;
    keepalive_timeout  65;
    root /home/ubuntu/api.gocode.cl;
    access_log /home/ubuntu/api.gocode.cl/logs/access.nginx.log;
    error_log  /home/ubuntu/api.gocode.cl/logs/error.nginx.log;
    client_max_body_size 8m;
    index index.php;

    gzip on;
    gzip_comp_level 3;
    gzip_min_length 150;
    gzip_proxied any;
    gzip_types text/plain;

    if ($request_method !~ ^(GET|HEAD|PUT|POST|DELETE|OPTIONS)$ ){
      return 405;
    }

    location /bulk_emails {
        include proxy_params;
        proxy_set_header Host $host;
        proxy_redirect off;
        proxy_pass http://unix:/home/ubuntu/projects/bulk_emails/bulk_emails.sock;
    }

    location ~ ^/(assets)/  {
      expires     max;
      add_header  Cache-Control public;
    }

    location = /favicon.ico {
      expires    max;
      add_header Cache-Control public;
    }

    location ~ \.php$ {
      try_files $uri =404;
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass unix:/run/php/php7.4-fpm.sock;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param PATH_INFO       $fastcgi_path_info;
      include fastcgi_params;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/api.gocode.cl/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/api.gocode.cl/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    if ($host = api.gocode.cl) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;

    server_name api.gocode.cl;
    return 404; # managed by Certbot
}
