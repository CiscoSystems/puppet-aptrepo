class aptrepo($basedir) {
  package { ["sbuild",
             "reprepro",
             "ubuntu-dev-tools"]:
    ensure => present
  }

  file { "${basedir}":
    ensure => directory
  }

  file { "/usr/local/share/keys":
    ensure => directory
  }

  file { "/usr/local/bin/refresh-schroots.sh":
    source => "puppet:///modules/aptrepo/refresh-schroots.sh",
    mode => "0755"
  }

  user { "buildd":
    managehome => true,
    ensure => present,
    require => Package[sbuild],
    groups => ["sbuild"]
  }

  file { "/home/buildd/.sbuildrc":
    source => "puppet:///modules/aptrepo/sbuildrc",
    owner => "buildd",
  }

  file { "/etc/sudoers.d/buildd":
    content => "Cmnd_Alias BUILDD_CMDS = /usr/bin/apt-get, /usr/sbin/adduser, /bin/mkdir, /usr/sbin/debootstrap, /bin/cp, /bin/bash, /usr/bin/tee, /bin/chmod, /usr/bin/sbuild-update, /usr/bin/schroot\nbuildd ALL= NOPASSWD: SETENV: BUILDD_CMDS",
    mode => "0440"
  }
}
