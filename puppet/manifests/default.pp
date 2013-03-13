###########################################################
# Base node configuration
###########################################################

include system, group 
include web, app, cache, database

class { 'iptables': allowports => [ 80, 443, 3306 ] }

###########################################################
# Specific node configuration
###########################################################


app::vhost { 'totsy': }
host { 'db_rw': ensure => present, ip => '127.0.0.1', name => 'db_read', host_aliases => 'db_write' }

