# module: cache

class cache {
  require system

  file { '/etc/redis.conf':
    source  => 'puppet:///modules/cache/redis.conf',
    owner   => 'root',
    group   => 'redis',
    mode    => '775',
    notify  => Service['redis'],
  }

  service { 'redis':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}

