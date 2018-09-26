# frozen_string_literal: true

conf = '/hab/svc/nginx-graphite/config'

describe file(File.join(conf, 'nginx.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      user hab;
      worker_processes  1;

      error_log /hab/svc/nginx-graphite/var/error.log error;
      pid /hab/svc/nginx-graphite/var/nginx.pid;

      events {
        worker_connections  4096;
      }

      worker_rlimit_nofile    4096;

      http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        # By default Nginx resolves upstream proxy_pass servers only once at start, DNS changes be damned...
        # Incuding resolver here in the http block will force nginx to resolve at request time, but only
        # for upstreams defined inline in location blocks (not those defined in server blocks.
        #    See:
        #        http://nginx.org/en/docs/http/ngx_http_upstream_module.html#resolve
        #        http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver
        #        https://www.ruby-forum.com/topic/4407628
        resolver 10.120.1.21 10.120.1.85 10.120.1.149 valid=30s;

        # standard combined log format up until http_user_agnet, with extra stuff after
        log_format socrata '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent '
                           '"$http_referer" "$http_user_agent" $request_length $request_time "$http_host" '
                           '"$http_X_Socrata_RequestId" "$http_X_App_Token" "$ssl_protocol" "$ssl_cipher" '
                           '"$upstream_http_X_Socrata_RequestId"';


        access_log /hab/svc/nginx-graphite/var/access.log socrata;
        error_log /hab/svc/nginx-graphite/var/http-error.log ;

        server_tokens off;

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;

        # reduces uneeded ssl handshakes
        ssl_session_cache   shared:SSL:10m;
        ssl_session_timeout 10m;

        # Set up a principled connection upgrade variable.
        map $http_upgrade $connection_upgrade {
          default upgrade;
          ''      close;
        }

        keepalive_timeout  65;

        gzip on;
        gzip_http_version 1.0;
        gzip_comp_level 2;
        gzip_proxied any;
        gzip_types application/javascript application/json application/pdf application/rdf+xml application/rss+xml application/vnd.geo+json application/vnd.ms-excel application/x-javascript application/xmlapplication/xml+rss image/bmp image/svg+xml text/css text/csv text/javascript text/plain text/xml;

        server_names_hash_bucket_size 64;

        proxy_max_temp_file_size 0;

        upstream django {
          ip_hash;
          server unix:/tmp/uwsgi.sock;
        }

        server {
          listen 8080;
          server_name graphite;
          charset utf-8;

          add_header "Access-Control-Allow-Origin" "*";
          add_header "Access-Control-Allow-Credentials" "false";
          add_header "Access-Control-Allow-Methods" "GET, OPTIONS";
          add_header "Access-Control-Allow-Headers" "Authorization, origin, accept";

          # Django admin media.
          location /media/admin/ {
            alias /usr/lib/python2.7/site-packages/django/contrib/admin/media/;
          }

          # static media.
          location /content/ {
            alias /opt/graphite/webapp/content/;
          }

          # all non-media requests to the Django server.
          location / {
            uwsgi_pass django;
            include uwsgi_params;
          }
        }
      }
    EXP
    should eq(expected)
  end
end
