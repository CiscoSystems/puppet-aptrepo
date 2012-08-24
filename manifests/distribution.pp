define aptrepo::distribution($repository, 
                             $suite,
                             $version,
                             $description = "",
                             $keyid,
                             $codename,
                             $ubuntu_series,
                             $origin = undef,
                             $label = undef,
                             $mirror_on_launchpad = false) {

  $newjobdir = "${::aptrepo::basedir}/work/queue/new"
  $reposdir = "${::aptrepo::basedir}/repos"
  $repodir = "${reposdir}/${repository}"
  $builders = [$extra_builders, $keyid]
  $distributions = "${repodir}/conf/distributions"
  $incoming = "${repodir}/conf/incoming"
  $pulls = "${repodir}/conf/pulls"

  concat::fragment { "distributions-${repository}-${name}":
    target => "${distributions}",
    content => template('aptrepo/reprepro.distributions.erb'),
  }

  concat::fragment { "incoming-${repository}-${name}":
    target => "${incoming}",
    content => template('aptrepo/reprepro.incoming.erb'),
  }

  concat::fragment { "pulls-${repository}-${name}":
    target => "${pulls}",
    content => template('aptrepo/reprepro.pulls.erb'),
  }

  cron { "${repository}-${name}-i386-refresh":
    command => "ubuntu_series=${ubuntu_series} series=${codename} repository=${repository} keyid=${keyid} architecture=i386 /usr/local/bin/refresh-schroots.sh",
    user => "buildd",
    hour => 2,
    minute => 0
  }

  cron { "${repository}-${name}-amd64-refresh":
    command => "ubuntu_series=${ubuntu_series} series=${codename} repository=${repository} keyid=${keyid} architecture=amd64 /usr/local/bin/refresh-schroots.sh",
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
