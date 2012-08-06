define aptrepo::distribution($suite,
                             $version,
                             $description = "",
                             $keyid,
                             $codename,
                             $origin = undef,
                             $label = undef,
                             $uploaders = [],
                             $builders = [],
                             $mirror_on_launchpad = false) {

  $newjobdir = "${::aptrepo::basedir}/work/queue/new"

  $reposdir = "${::aptrepo::basedir}/repos"
  $repodir = "${reposdir}/$name"

  file { "${repodir}":
    ensure => directory
  }

  file { "${repodir}/conf":
    ensure => directory
  }

  file { "${repodir}/incoming":
    ensure => directory
  }

  file { "${repodir}/conf/dput.cf":
    content => template('aptrepo/dput.cf.erb')
  }

  file { "${repodir}/conf/distributions":
    content => template('aptrepo/reprepro.distributions.erb')
  }

  file { "${repodir}/conf/incoming":
    content => template('aptrepo/reprepro.incoming.erb')
  }

  file { "${repodir}/conf/options":
    content => template('aptrepo/reprepro.options.erb')
  }

  file { "${repodir}/conf/pulls":
    content => template('aptrepo/reprepro.pulls.erb')
  }

  file { "${repodir}/conf/sign-and-upload":
    content => template('aptrepo/reprepro.sign-and-upload.erb'),
    mode => "0755",
  }

  file { "${repodir}/conf/create-build-jobs.sh":
    content => template('aptrepo/reprepro.create-build-jobs.sh.erb'),
    mode => "0755",
  }

  file { "${repodir}/conf/uploaders":
    content => template('aptrepo/reprepro.uploaders.erb')
  }

  cron { "${name}-i386-refresh":
    command => "series=$suite repository=$name architecture=i386 keyid=$keyid /usr/local/bin/refresh-schroots.sh",
    user => root,
    hour => 2,
    minute => 0
  }

  cron { "${name}-amd64-refresh":
    command => "series=$suite repository=$name architecture=amd64 keyid=$keyid /usr/local/bin/refresh-schroots.sh",
    user => root,
    hour => 2,
    minute => 30
  }
}
