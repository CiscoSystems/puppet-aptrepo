define aptrepo::distribution($suite,
                             $version,
                             $description = "",
                             $keyid,
                             $codename,
                             $origin = undef,
                             $label = undef,
                             $uploaders = [],
                             $wwwdir = undef,
                             $mirror_on_launchpad = false) {

  $newjobdir = "${::aptrepo::basedir}/work/queue/new"

  $reposdir = "${::aptrepo::basedir}/repos"
  $repodir = "${reposdir}/$name"
  $builders = [$keyid]

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

  file { "${repodir}/conf/distributions":
    content => template('aptrepo/reprepro.distributions.erb'),
    owner => "buildd"
  }

  file { "${repodir}/conf/incoming":
    content => template('aptrepo/reprepro.incoming.erb'),
    owner => "buildd"
  }

  file { "${repodir}/conf/options":
    content => template('aptrepo/reprepro.options.erb'),
    owner => "buildd"
  }

  file { "${repodir}/conf/pulls":
    content => template('aptrepo/reprepro.pulls.erb'),
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

  cron { "${name}-i386-refresh":
    command => "series=$suite repository=$name architecture=i386 keyid=$keyid /usr/local/bin/refresh-schroots.sh",
    user => "buildd",
    hour => 2,
    minute => 0
  }

  cron { "${name}-amd64-refresh":
    command => "series=$suite repository=$name architecture=amd64 keyid=$keyid /usr/local/bin/refresh-schroots.sh",
    user => "buildd",
    hour => 2,
    minute => 30
  }

  file { "/srv/ftp/$name":
    ensure => directory
  }

  mount { "/srv/ftp/$name":
    ensure => "mounted",
    device => "${repodir}/incoming",
    options => "bind",
    fstype => "none",
    require => [File["/srv/ftp/$name"], File["${repodir}/incoming"]], 
  }    
}
