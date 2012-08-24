define aptrepo::repository($keyid,
                           $uploaders = [],
                           $extra_builders = [],
                           $wwwdir = undef) {

  include concat::setup

  $newjobdir = "${::aptrepo::basedir}/work/queue/new"
  $reposdir = "${::aptrepo::basedir}/repos"
  $repodir = "${reposdir}/${name}"
  $builders = [$extra_builders, $keyid]

  $distributions = "${repodir}/conf/distributions"
  $incoming = "${repodir}/conf/incoming"
  $pulls = "${repodir}/conf/pulls"

  file { "${repodir}":
    ensure => directory,
    owner => "buildd"
  }

  if ($wwwdir) {
    file { "${wwwdir}/${name}":
      ensure => "link",
      target => "${repodir}/repo"
    }
  }

  file { "${repodir}/conf":
    ensure => directory,
    owner => "buildd"
  }

  file { "${repodir}/incoming":
    ensure => directory,
    owner => "buildd",
    mode => "1777"
  }

  file { "${repodir}/conf/dput.cf":
    content => template('aptrepo/dput.cf.erb'),
    owner => "buildd"
  }

  file { "${repodir}/conf/options":
    content => template('aptrepo/reprepro.options.erb'),
    owner => "buildd"
  }

  concat { "$distributions":
    owner => "buildd"
  }

  concat { "${incoming}":
    owner => "buildd"
  }

  concat::fragment { "${name}-incoming-head":
    order => 14,
    target => "${incoming}",
    content => "Name: incoming\nIncomingDir: incoming\nTempdir: tmp\nPermit: unused_files\nCleanup: unused_files on_error\nAllow: ",
  }

  concat::fragment { "${name}-incoming-tail":
    order => 16,
    target => "${incoming}",
    content => "\n\n",
  }

  concat { "${pulls}":
    owner => "buildd"
  }

  file { "${repodir}/conf/sign-and-upload":
    content => template('aptrepo/reprepro.sign-and-upload.erb'),
    mode => "0755",
    owner => "buildd"
  }

  file { "${repodir}/conf/create-build-jobs.sh":
    content => template('aptrepo/reprepro.create-build-jobs.sh.erb'),
    mode => "0755",
    owner => "buildd"
  }

  file { "${repodir}/conf/uploaders":
    content => template('aptrepo/reprepro.uploaders.erb'),
    owner => "buildd"
  }

}
