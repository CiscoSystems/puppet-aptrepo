define aptrepo::distribution($repository, 
                             $suite,
                             $version,
                             $description = "",
                             $keyid,
                             $codename,
                             $ubuntu_series,
                             $origin = undef,
                             $label = undef,
                             $mirror_on_launchpad = false,
                             $lp_ppa_name = "") {

  $newjobdir = "${::aptrepo::basedir}/work/queue/new"
  $reposdir = "${::aptrepo::basedir}/repos"
  $repodir = "${reposdir}/${repository}"
  $builders = [$extra_builders, $keyid]
  $distributions = "${repodir}/conf/distributions"
  $incoming = "${repodir}/conf/incoming"
  $pulls = "${repodir}/conf/pulls"

  if ($lp_ppa_name == "") {
    $lp_ppa_name = $name
  }

  concat::fragment { "distributions-${repository}-${name}":
    target => "${distributions}",
    content => template('aptrepo/reprepro.distributions.erb'),
  }

  concat::fragment { "incoming-${repository}-${name}":
    order => 15,
    target => "${incoming}",
    content => "${codename}>${codename}-proposed ",
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

  file { "${repodir}/conf/sign-and-upload-${name}":
    content => template('aptrepo/reprepro.sign-and-upload.erb'),
    mode => "0755",
    owner => "buildd"
  }

}
