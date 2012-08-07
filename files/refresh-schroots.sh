#!/bin/bash

cd /
        
if [ -z "$(schroot -l | grep source:${series}-${repository}-${architecture})" ]
then
    mk_sbuild_extra_args=""

    if [ -n "$proxy" ]
    then
        mk_sbuild_extra_args="${mk_sbuild_extra_args} --debootstrap-proxy=${proxy}"
    fi

    if [ -n "$mirror" ]
    then
        mk_sbuild_extra_args="${mk_sbuild_extra_args} --debootstrap-mirror=${mirror}"
    fi

    mk-sbuild --name=${series}-${repository} \
              --arch=${architecture} \
              ${mk_sbuild_extra_args} \
              ${series}

    echo 'Acquire::http::Proxy::127.0.0.1 "DIRECT";' | schroot -c ${series}-${repository}-${architecture}-source -u root -- tee --append /etc/apt/apt.conf.d/99mk-sbuild-proxy
    echo "deb http://127.0.0.1/repos/${repository} $series main" | schroot -c ${series}-${repository}-${architecture}-source -u root -- tee --append /etc/apt/sources.list
    echo "deb-src http://127.0.0.1/repos/${repository} $series main" | schroot -c ${series}-${repository}-${architecture}-source -u root -- tee --append /etc/apt/sources.list
    echo "deb http://127.0.0.1/repos/${repository} ${series}-proposed main" | schroot -c ${series}-${repository}-${architecture}-source -u root -- tee --append /etc/apt/sources.list
    echo "deb-src http://127.0.0.1/repos/${repository} ${series}-proposed main" | schroot -c ${series}-${repository}-${architecture}-source -u root -- tee --append /etc/apt/sources.list
    gpg -a --export ${keyid} | schroot -c ${series}-${repository}-${architecture}-source -u root -- apt-key add -

fi

sbuild-update -udcar ${series}-${repository} --arch=${architecture}
