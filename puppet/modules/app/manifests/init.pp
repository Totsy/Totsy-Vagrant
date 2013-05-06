# module: app

class app {
  $environment = 'dev'

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
  }
 
  file { '/etc/php.ini':
    source  => 'puppet:///modules/app/php.ini',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
  }

  file { '/etc/php-fpm.conf':
    source  => 'puppet:///modules/app/php-fpm.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
  }

  file { '/etc/php-fpm.d/www.conf':
    source  => 'puppet:///modules/app/php-fpm.d/www.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
  }

  file { '/etc/php.d/apc.ini':
    source  => 'puppet:///modules/app/php.d/apc.ini',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
  }

  file { '/etc/php.d/redis.ini':
    source  => 'puppet:///modules/app/php.d/redis.ini',
    owner   => 'root',
    group   => 'root',
    mode    => '604',
    notify  => Service['php-fpm'],
  }

  file { '/etc/nginx/fastcgi_params':
    source  => 'puppet:///modules/app/fastcgi_params',
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '604',
    notify  => Service['nginx'],
  }

  file { '/etc/magento/local.xml':
    content => template('app/local.xml.erb'),
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '664',
    require => File[$sitedirs]
  }

  file { '/etc/magento/litle_SDK_config.ini':
    source  => 'puppet:///modules/app/litle_SDK_config.ini',
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '664',
    require => File[$sitedirs]
  }


  file { '/vagrant/www/Totsy-Magento/app/etc/local.xml':
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

  file { '/vagrant-mirror/www/Totsy-Magento/app/code/community/Litle/LitleSDK/litle_SDK_config.ini':
    source  => 'puppet:///modules/app/litle_SDK_config.ini',
    owner   => 'nobody',
    group   => 'nobody',
    mode    => '775',
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
  }

  file { '/srv/share':
    ensure => directory
  }

  exec { "tar -xzf /vagrant-www/media.tgz -C /vagrant-www/Totsy-Magento":
    creates => "/vagrant-www/Totsy-Magento/media",
    path    => "/usr/bin:/bin",
  }

  exec { "extract magento":
    command => "tar -xjf /usr/share/magento/magento-enterprise-1.11.1.tar.bz2 -C /vagrant-www/Totsy-Magento --strip-components=1",
    creates => "/vagrant-www/Totsy-Magento/downloader",
    path    => "/usr/bin:/bin",
  }
  
  exec { "git reset --hard HEAD":
    path     => "/usr/bin:/bin",
    cwd      => "/vagrant/www/Totsy-Magento",
    require  => Exec["extract magento"]
  }
}

