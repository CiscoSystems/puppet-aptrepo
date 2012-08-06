class aptrepo($basedir) {
  package { ["sbuild",
             "reprepro",
             "ubuntu-dev-tools",
             "run-one"]:
    ensure => present
  }

  file { "${basedir}":
    ensure => directory
  }

  file { "${basedir}/repos":
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

  file { "/usr/local/bin/process-build-queue.sh":
    source => "puppet:///modules/aptrepo/process-build-queue.sh",
    mode => "0755",
    owner => "root",
    group => "root"
  }

  file { "/usr/local/bin/process-uploads.sh":
    source => "puppet:///modules/aptrepo/process-uploads.sh",
    mode => "0755",
    owner => "root",
    group => "root"
  }

  cron { "process-uploads":
    command => "basedir=${basedir} /usr/bin/run-one /usr/local/bin/process-uploads.sh",
    user => root,
  }

  cron { "process-build-queue":
    command => "basedir=${basedir}/work /usr/bin/run-one /usr/local/bin/process-build-queue.sh run",
    user => root,
  }

  file { "${basedir}/work":
    ensure => directory
  }

  exec { "/usr/local/bin/process-build-queue.sh init":
    creates => "${basedir}/work/queue",
    environment => ["basedir=${basedir}/work"],
    require => [File["${basedir}/work"],
                File["/usr/local/bin/process-build-queue.sh"]],
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
