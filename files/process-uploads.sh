#!/bin/sh -ex
        
export GNUPGHOME=$HOME/apt/.gnupg

repodir="${repodir:-${basedir}/repos}"

cd "${repodir}"

for flavour in *
do
    if [ "${flavour}" == README ]
    then
        continue
    fi

    reprepro -b ${basedir}/${flavour} processincoming incoming
done
reprepro -b $HOME/apt/@repository@ export
