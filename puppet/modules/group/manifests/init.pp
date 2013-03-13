# module: group

class group {
  group { 'superadmins':
    ensure => 'present'
  }
}

