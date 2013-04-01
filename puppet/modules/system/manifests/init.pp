# Generic system properties for all nodes
class system {

  file { '/etc/yum.conf':
    source => 'puppet:///modules/system/yum.conf',
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/etc/bashrc':
    source  => 'puppet:///modules/system/bashrc',
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/sysconfig/clock':
    source  => 'puppet:///modules/system/clock',
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/localtime':
    ensure  => 'link',
    target  => '/usr/share/zoneinfo/UTC',
  } 
 
  case $hostname { 
    master:         { $sudoers = "sudoers.master" }
    default:        { $sudoers = "sudoers" }
    /^web\d+-dc0$/: { $sudoers = "sudoers.web" }
    /^web-/:        { $sudoers = "sudoers.web" }
  }

  file { '/etc/sudoers':
    source  => "puppet:///modules/system/$sudoers",
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
  }

  # Some core services

  package { 'rsyslog':
    ensure => '5.8.10-6.el6'
  }
  file { "/etc/rsyslog.conf":
    content => template("system/rsyslog.conf.erb"),
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600'
  }
  service { 'rsyslog':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/rsyslog.conf'],
  }

  file { '/etc/ssh/sshd_config':
    content => template("system/sshd_config.erb"),
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }
  service { 'sshd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/ssh/sshd_config'],
  }

  package { 'cronie':
    ensure => latest
  }

  service { 'crond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['cronie']
  }

  package { 'ntp':
    ensure => latest
  }
  service { 'ntpd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['ntp'],
  }

  package { 'acpid':
    ensure => latest
  }
  service { 'acpid':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['acpid'],
  }

  package { 'sudo':        ensure => latest }
  package { 'rsync':       ensure => latest }
  package { 'tar':         ensure => latest }
  package { 'ruby-shadow': ensure => latest }

  yumrepo { 'totsyrepo':
    baseurl  => 'http://repo.totsy.com/6/x86_64/',
    name     => 'totsy',
    descr    => 'Totsy Repository',
    enabled  => 1,
    gpgcheck => 0
  }

}
