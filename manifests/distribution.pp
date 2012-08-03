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
  file { "${::aptrepo::basedir}/$name":
    ensure => directory
  }

  file { "${::aptrepo::basedir}/$name/conf":
    ensure => directory
  }

  file { "${::aptrepo::basedir}/$name/conf/incoming":
    content => template('aptrepo/reprepro.incoming.erb')
  }

  file { "${::aptrepo::basedir}/$name/conf/options":
    content => template('aptrepo/reprepro.options.erb')
  }

  file { "${::aptrepo::basedir}/$name/conf/pulls":
    content => template('aptrepo/reprepro.pulls.erb')
  }

  file { "${::aptrepo::basedir}/$name/conf/sign-and-upload":
    content => template('aptrepo/reprepro.sign-and-upload.erb')
  }

  file { "${::aptrepo::basedir}/$name/conf/uploaders":
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
