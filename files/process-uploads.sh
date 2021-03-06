#!/bin/sh -ex
        
repodir="${repodir:-${basedir}/repos}"

cd "${repodir}"

for flavour in *
do
    if [ "${flavour}" = README ]
    then
        continue
    fi

    reprepro -V -b ${repodir}/${flavour} processincoming incoming
    reprepro -V -b ${repodir}/${flavour} export
done
