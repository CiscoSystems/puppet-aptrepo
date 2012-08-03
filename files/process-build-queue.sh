#!/bin/bash -e

export GNUPGHOME=$HOME/apt/.gnupg

workerid="$HOSTNAME.$$"

basedir="${basedir:-.}"
logdir="${logdir:-${basedir}/logs}"
queuedir="${queuedir:-${basedir}/queue}"
newjobsdir="${newjobsdir:-${queuedir}/new}"
runningjobsdir="${runningjobsdir:-${queuedir}/running}"
finishedjobsdir="${finishedjobsdir:-${queuedir}/finished}"

if [ "$1" == "init" ]
then
    mkdir -p "${logdir}"
    mkdir -p "${queuedir}"
    mkdir -p "${newjobsdir}"
    mkdir -p "${runningjobsdir}"
    mkdir -p "${finishedjobsdir}"
elif [ "$1" == "run" ]
then
    cd "${queuedir}/new"

    for x in *
    do
        if [ ! -x "${x}" ]
        then
            continue
        fi

        timestamp="$(date +%Y%m%d.%H%m%S)"
        workfile="${runningjobsdir}/${x}.${workerid}"
        logfile="${logdir}/${x}.${workerid}.${timestamp}"

        mv "${x}" "${workfile}" || continue # If this fails, another worker probably got around to it before this one
        exec 3>&1 4>&2
        exec > "${logfile}" 2>&1
        set +ex
        ${workfile}
        exitcode=$?
        echo Exit code: $exitcode
        set -ex
        exec 1>&3 2>&4
        mv "${workfile}" "${finishedjobsdir}"
    done
fi
