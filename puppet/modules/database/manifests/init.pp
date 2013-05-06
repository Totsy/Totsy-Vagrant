# module: database

class database ($environment = 'dev') {


  service { 'mysql':
    ensure => running,
    require => File['/etc/my.cnf']
  }

  file { '/etc/my.cnf':
    content => template("database/${environment}.my.cnf.erb"),
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '644',
    notify  => Service['mysql'],
  }

  
  $nc = "/usr/bin/mysqladmin status"

  exec { 'wait-for-mysql':
    command     => "while ! ${nc}; do sleep 1; done",
    provider    => shell,
    timeout     => 30,
      require => [Service['mysql'],File['/etc/my.cnf']]
  }

  exec {
        "Restore Database":
            command => "gunzip < /vagrant/www/db.sql.gz | mysql -uroot && chown -R mysql:mysql /var/lib/mysql",
            path    => "/usr/bin:/bin",
            require => Exec['wait-for-mysql']
  }

  file { "/var/lib/mysql": 
    ensure => directory, 
    owner => "mysql", 
    group => "mysql", 
    mode => 775,
    recurse => true,
    require => Exec['Restore Database'],
    ignore => 'mysql.sock'
  } 

  exec { 'reset-mage-inventory':
    command => "/bin/cp /vagrant/www/mage_shell_reset_inventory.php /vagrant/www/Totsy-Magento/shell/; cd /vagrant/www/Totsy-Magento/shell/; /usr/bin/php /vagrant/www/Totsy-Magento/shell/mage_shell_reset_inventory.php runall; /bin/rm /vagrant/www/Totsy-Magento/shell/mage_shell_reset_inventory.php",
    require => File['/var/lib/mysql'],
    path => '/bin;/usr/bin'
  }
}
