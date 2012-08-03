define aptrepo::key($keydata, $id, $user = 'root') {
  if ($user == "root") {
    $home = "/root"
  } else {
    $home = "/home/$user"
  }

  User<| name == $user |> ->

  file { "/usr/local/share/keys/$name":
    content => $keydata,
    owner => $user,
    mode => "0400"
  } ->

  exec { "/usr/bin/gpg --import /usr/local/share/keys/$name":
    unless => "/usr/bin/gpg --list-keys | grep $id",
    user => $user,
    environment => ["HOME=$home"],
    logoutput => on_failure
  }
}
