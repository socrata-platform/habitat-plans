# frozen_string_literal: true

pkg_svc_config_path = '/hab/svc/nginx-graphite/config'
graphite_web_pkg_path = command('hab pkg path socrata/graphite-web').stdout
                                                                    .strip

expected_conf = <<-EXP.gsub(/^ {2}/, '')
  daemon off;
  worker_processes 1;

  error_log /hab/svc/nginx-graphite/var/error.log error;
  pid /hab/svc/nginx-graphite/var/nginx.pid;

  events {
    worker_connections 4096;
  }

  worker_rlimit_nofile 4096;

  http {
    include #{pkg_svc_config_path}/mime.types;
    default_type application/octet-stream;

    # standard combined log format up until http_user_agnet, with extra stuff after
    log_format custom '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent" $request_length $request_time "$http_host" '
                      '"$http_X_Socrata_RequestId" "$http_X_App_Token" "$ssl_protocol" "$ssl_cipher" '
                      '"$upstream_http_X_Socrata_RequestId"';


    access_log /hab/svc/nginx-graphite/var/access.log custom;
    error_log /hab/svc/nginx-graphite/var/http-error.log;

    server_tokens off;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    # reduces uneeded ssl handshakes
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Set up a principled connection upgrade variable.
    map $http_upgrade $connection_upgrade {
      default upgrade;
      ''      close;
    }

    keepalive_timeout 65;

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

      client_body_temp_path /hab/svc/nginx-graphite/var/client-body;
      proxy_temp_path /hab/svc/nginx-graphite/var/proxy;
      fastcgi_temp_path /hab/svc/nginx-graphite/var/fastcgi;
      scgi_temp_path /hab/svc/nginx-graphite/var/scgi;
      uwsgi_temp_path /hab/svc/nginx-graphite/var/uwsgi;

      add_header "Access-Control-Allow-Origin" "*";
      add_header "Access-Control-Allow-Credentials" "false";
      add_header "Access-Control-Allow-Methods" "GET, OPTIONS";
      add_header "Access-Control-Allow-Headers" "Authorization, origin, accept";

      # Django admin media.
      location /media/admin/ {
        alias #{graphite_web_pkg_path}/lib/python2.7/site-packages/django/contrib/admin/media/;
      }

      # static media.
      location /content/ {
        alias #{graphite_web_pkg_path}/webapp/content/;
      }

      # all non-media requests to the Django server.
      location / {
        uwsgi_pass django;
        include #{pkg_svc_config_path}/uwsgi_params;
      }
    }
  }
EXP

describe file(File.join(pkg_svc_config_path, 'nginx.conf')) do
  its(:content) { should eq(expected_conf) }
end

expected_uwsgi = <<-EXP.gsub(/^ {2}/, '')

  uwsgi_param  QUERY_STRING       $query_string;
  uwsgi_param  REQUEST_METHOD     $request_method;
  uwsgi_param  CONTENT_TYPE       $content_type;
  uwsgi_param  CONTENT_LENGTH     $content_length;

  uwsgi_param  REQUEST_URI        $request_uri;
  uwsgi_param  PATH_INFO          $document_uri;
  uwsgi_param  DOCUMENT_ROOT      $document_root;
  uwsgi_param  SERVER_PROTOCOL    $server_protocol;
  uwsgi_param  HTTPS              $https if_not_empty;

  uwsgi_param  REMOTE_ADDR        $remote_addr;
  uwsgi_param  REMOTE_PORT        $remote_port;
  uwsgi_param  SERVER_PORT        $server_port;
  uwsgi_param  SERVER_NAME        $server_name;
EXP

describe file(File.join(pkg_svc_config_path, 'uwsgi_params')) do
  its(:content) { should eq(expected_uwsgi) }
end

expected_mime = <<-EXP.gsub(/^ {2}/, '')

  types {
      text/html                             html htm shtml;
      text/css                              css;
      text/xml                              xml;
      image/gif                             gif;
      image/jpeg                            jpeg jpg;
      application/javascript                js;
      application/atom+xml                  atom;
      application/rss+xml                   rss;

      text/mathml                           mml;
      text/plain                            txt;
      text/vnd.sun.j2me.app-descriptor      jad;
      text/vnd.wap.wml                      wml;
      text/x-component                      htc;

      image/png                             png;
      image/tiff                            tif tiff;
      image/vnd.wap.wbmp                    wbmp;
      image/x-icon                          ico;
      image/x-jng                           jng;
      image/x-ms-bmp                        bmp;
      image/svg+xml                         svg svgz;
      image/webp                            webp;

      application/font-woff                 woff;
      application/java-archive              jar war ear;
      application/json                      json;
      application/mac-binhex40              hqx;
      application/msword                    doc;
      application/pdf                       pdf;
      application/postscript                ps eps ai;
      application/rtf                       rtf;
      application/vnd.apple.mpegurl         m3u8;
      application/vnd.ms-excel              xls;
      application/vnd.ms-fontobject         eot;
      application/vnd.ms-powerpoint         ppt;
      application/vnd.wap.wmlc              wmlc;
      application/vnd.google-earth.kml+xml  kml;
      application/vnd.google-earth.kmz      kmz;
      application/x-7z-compressed           7z;
      application/x-cocoa                   cco;
      application/x-java-archive-diff       jardiff;
      application/x-java-jnlp-file          jnlp;
      application/x-makeself                run;
      application/x-perl                    pl pm;
      application/x-pilot                   prc pdb;
      application/x-rar-compressed          rar;
      application/x-redhat-package-manager  rpm;
      application/x-sea                     sea;
      application/x-shockwave-flash         swf;
      application/x-stuffit                 sit;
      application/x-tcl                     tcl tk;
      application/x-x509-ca-cert            der pem crt;
      application/x-xpinstall               xpi;
      application/xhtml+xml                 xhtml;
      application/xspf+xml                  xspf;
      application/zip                       zip;

      application/octet-stream              bin exe dll;
      application/octet-stream              deb;
      application/octet-stream              dmg;
      application/octet-stream              iso img;
      application/octet-stream              msi msp msm;

      application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
      application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

      audio/midi                            mid midi kar;
      audio/mpeg                            mp3;
      audio/ogg                             ogg;
      audio/x-m4a                           m4a;
      audio/x-realaudio                     ra;

      video/3gpp                            3gpp 3gp;
      video/mp2t                            ts;
      video/mp4                             mp4;
      video/mpeg                            mpeg mpg;
      video/quicktime                       mov;
      video/webm                            webm;
      video/x-flv                           flv;
      video/x-m4v                           m4v;
      video/x-mng                           mng;
      video/x-ms-asf                        asx asf;
      video/x-ms-wmv                        wmv;
      video/x-msvideo                       avi;
  }
EXP

describe file(File.join(pkg_svc_config_path, 'mime.types')) do
  its(:content) { should eq(expected_mime) }
end
