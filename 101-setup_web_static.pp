# Configures a web server for deployment of web_static.

# Nginx configuration file
$nginx_conf = "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    add_header X-Served-By ${hostname};
    root   /var/www/html;
    index  index.html index.htm;
    location /hbnb_static {
        alias /data/web_static/current;
        index index.html index.htm;
    }
    location /redirect_me {
        return 301 https://th3-gr00t.tk;
    }
    error_page 404 /404.html;
    location /404 {
      root /var/www/html;
      internal;
    }
}"

package { 'nginx':
  ensure   => 'present',
  provider => 'apt',
} ->

file { '/data':
  ensure  => 'directory',
} ->

file { '/data/web_static':
  ensure => 'directory',
} ->

file { '/data/web_static/releases':
  ensure => 'directory',
} ->

file { '/data/web_static/releases/test':
  ensure => 'directory',
} ->

file { '/data/web_static/shared':
  ensure => 'directory',
} ->

file { '/data/web_static/releases/test/index.html':
  ensure  => 'present',
  content => '<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>',
} ->



file { '/data/web_static/current':
  ensure => 'link',
  target => '/data/web_static/releases/test',
} ->

exec { 'chown -R ubuntu:ubuntu /data/':
  path    => '/usr/bin/:/usr/local/bin/:/bin/',
  require => File['/data/web_static/current'],
}

file { '/var/www':
  ensure => 'directory',
} ->

file { '/var/www/html':
  ensure => 'directory',
} ->

file { '/var/www/html/index.html':
  ensure  => 'present',
  content => "Holberton School Nginx\n",
  require => File['/var/www/html'],
} ->

file { '/var/www/html/404.html':
  ensure  => 'present',
  content => "Ceci n'est pas une page\n",
  require => File['/var/www/html'],
} ->

file { '/etc/nginx/sites-available/default':
  ensure  => 'present',
  content => $nginx_conf,
  require => Package['nginx'],
} ->

exec { 'nginx-restart':
  command => '/etc/init.d/nginx restart',
  path    => '/etc/init.d/',
  require => File['/etc/nginx/sites-available/default'],
}
