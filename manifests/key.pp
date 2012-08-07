define aptrepo::key($keydata = 'fetch') {
  $home = "/home/buildd"
  $id = $name

  if ($keydata == 'fetch') {
    exec { "/usr/bin/gpg --recv-keys $id":
      unless => "/usr/bin/gpg --list-keys | grep $id",
      user => "buildd",
      environment => ["HOME=$home"],
    }
  } else {
    file { "/usr/local/share/keys/$name":
      content => $keydata,
      owner => "buildd",
      mode => "0400"
    } ->
    exec { "/usr/bin/gpg --import /usr/local/share/keys/$name":
      unless => "/usr/bin/gpg --list-keys | grep $id",
      user => "buildd",
      environment => ["HOME=$home"],
    }
  }
}
