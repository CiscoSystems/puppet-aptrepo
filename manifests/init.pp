class aptrepo($basedir) {
  package { ["sbuild",
             "reprepro",
             "ubuntu-dev-tools",
             "run-one",
             "vsftpd"]:
    ensure => present
  }

  file { "/var/log/aptrepo.log":
    owner => buildd,
    mode => "0644",
  }

  file { "/etc/vsftpd.conf":
    source => "puppet:///modules/aptrepo/vsftpd.conf",
    mode => 0644,
    owner => root,
    group => root,
    require => Package[vsftpd],
    notify => Exec[reload-vsftpd]
  }

  exec { "reload-vsftpd":
    command => "/sbin/restart vsftpd",
    refreshonly => true
  }

  file { "${basedir}":
    ensure => directory,
    owner => "buildd"
  }

  file { "${basedir}/repos":
    ensure => directory,
    owner => "buildd"
  }

  file { "/usr/local/share/keys":
    ensure => directory
  }

  file { "/usr/local/bin/refresh-schroots.sh":
    source => "puppet:///modules/aptrepo/refresh-schroots.sh",
    mode => "0755",
    owner => "buildd"
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
    command => "basedir=${basedir} /usr/bin/run-one /usr/local/bin/process-uploads.sh >> /var/log/aptrepo.log",
    user => "buildd",
  }

  cron { "process-build-queue":
    command => "basedir=${basedir}/work /usr/bin/run-one /usr/local/bin/process-build-queue.sh run >> /var/log/aptrepo.log",
    user => "buildd",
  }

  file { "${basedir}/work":
    ensure => directory,
    owner => "buildd"
  }

  exec { "/usr/local/bin/process-build-queue.sh init":
    creates => "${basedir}/work/queue",
    environment => ["basedir=${basedir}/work"],
    require => [File["${basedir}/work"],
                File["/usr/local/bin/process-build-queue.sh"]],
    user => "buildd"
  }

  file { "/home/buildd/.sbuildrc":
    source => "puppet:///modules/aptrepo/sbuildrc",
    owner => "buildd",
  }

  file { "/etc/sudoers.d/buildd":
    content => "Cmnd_Alias BUILDD_CMDS = /usr/bin/apt-get, /usr/sbin/adduser, /bin/mkdir, /bin/sed, /usr/sbin/debootstrap, /bin/cp, /bin/bash, /usr/bin/tee, /bin/chmod, /usr/bin/sbuild-update, /usr/bin/schroot\nbuildd ALL= NOPASSWD: SETENV: BUILDD_CMDS",
    mode => "0440"
  }
}
