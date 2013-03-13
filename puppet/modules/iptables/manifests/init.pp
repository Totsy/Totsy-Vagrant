# module: iptables
class iptables ($allowports = undef) {
  file { '/etc/sysconfig/iptables':
    content => template("iptables/config"),
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  service { 'iptables':
    hasrestart => true,
    subscribe  => File['/etc/sysconfig/iptables'],
  }
}

