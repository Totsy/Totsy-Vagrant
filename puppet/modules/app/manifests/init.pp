# module: app

class app {
  $environment = 'dev'

  $phpcore = [
    'php',
    'php-cli',
    'php-common',
    'php-devel',
    'php-fpm',
    'php-gd',
    'php-mcrypt',
    'php-mysql',
    'php-pdo',
    'php-soap',
    'php-xml',
  ]

  $sitedirs = [
    '/etc/nginx/sites-available',
    '/etc/nginx/sites-enabled',
    '/usr/share/magento',
    '/etc/magento'
  ]

  $redis_obj_host = '127.0.0.1'
  $redis_obj_port = '6379'
  $redis_session_host = '127.0.0.1'
  $redis_session_port = '6379'

  file { $sitedirs:
    ensure  => directory,
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '775',
    require => Package['nginx']
  }

  package { $phpcore:
    ensure  => '5.3.20-13.el6.art'
  }

  package {
    'php-pecl-apc':       ensure => '3.1.9-3.el6.art';
    'php-pecl-memcache':  ensure => absent;
    'php-ioncube-loader': ensure => '4.0.5-1.el6.art';
    'php-pecl-igbinary':  ensure => '1.1.1-3.el6.remi';
    'php-redis':          ensure => '2.2.2-5.git6f7087f.el6';

    'nfs-utils': ensure => latest;
    'git':       ensure => latest
  }
 
  file { '/etc/php.ini':
    source  => 'puppet:///modules/app/php.ini',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
    require => Package['php-fpm']
  }

  file { '/etc/php-fpm.conf':
    source  => 'puppet:///modules/app/php-fpm.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
    require => Package['php-fpm']
  }

  file { '/etc/php-fpm.d/www.conf':
    source  => 'puppet:///modules/app/php-fpm.d/www.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
    require => Package['php-fpm']
  }

  file { '/etc/php.d/apc.ini':
    source  => 'puppet:///modules/app/php.d/apc.ini',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
    require => Package['php-fpm']
  }

  file { '/etc/php.d/redis.ini':
    source  => 'puppet:///modules/app/php.d/redis.ini',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
    require => Package['php-fpm']
  }

  file { '/etc/nginx/fastcgi_params':
    source  => 'puppet:///modules/app/fastcgi_params',
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '604',
    notify  => Service['nginx'],
    require => Package['nginx']
  }

  file { '/etc/magento/local.xml':
    content => template('app/local.xml.erb'),
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '664',
    require => File[$sitedirs]
  }

  file { '/vagrant-www/Totsy-Magento/app/etc/local.xml':
    content => template('app/local.xml.erb'),
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '664',
    require => File[$sitedirs]
  }

  file { '/etc/magento/local.twolevels.xml':
    content => template('app/local.twolevels.xml.erb'),
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '664',
    require => File[$sitedirs]
  }

  file { '/etc/magento/local.xml.phpunit':
    content => template('app/local.xml.phpunit.erb'),
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '664',
    require => File[$sitedirs]
  }

  file { '/usr/share/magento/magento-enterprise-1.11.1.tar.bz2':
    source  => 'puppet:///modules/app/magento-enterprise-1.11.1.tar.bz2',
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '775',
    require => File[$sitedirs]
  }

  file { '/usr/local/bin/git-precommit-chkdebug':
    source => 'puppet:///modules/app/git-precommit-chkdebug',
    owner  => 'root',
    group  => 'root',
    mode   => '775'
  }

  service { 'php-fpm':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package[$phpcore]
  }

  file { '/srv/share':
    ensure => directory
  }

  # Install PHP Composer
  exec { "curl -s https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer":
    creates => "/usr/local/bin/composer",
    path    => "/usr/bin:/bin"
  }

  exec { "tar -xzf /vagrant-www/media.tgz -C /vagrant-www/Totsy-Magento":
    creates => "/vagrant-www/Totsy-Magento/media",
    path    => "/usr/bin:/bin",
    require => Package[tar] 
  }

  exec { "extract magento":
    command => "tar -xjf /usr/share/magento/magento-enterprise-1.11.1.tar.bz2 -C /vagrant-www/Totsy-Magento --strip-components=1",
    creates => "/vagrant-www/Totsy-Magento/downloader",
    path    => "/usr/bin:/bin",
    require => Package[tar]
  }
  
  exec { "git reset --hard HEAD":
    path     => "/usr/bin:/bin",
    cwd      => "/vagrant-www/Totsy-Magento",
    require  => [Package[git],Exec["extract magento"]]
  }
}

