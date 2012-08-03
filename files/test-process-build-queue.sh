#!/bin/bash -e

basedir=$(mktemp -d)
export basedir
trap "echo Cleaning up; rm -rf ${basedir}" ERR EXIT 

echo "Running init"
./process-build-queue.sh init

echo "Testing if logs dir was created"
test -d ${basedir}/logs
echo "Testing if queue dir was created"
test -d ${basedir}/queue
echo "Testing if incoming jobs dir was created"
test -d ${basedir}/queue/new
echo "Testing if runnings jobs dir was created"
test -d ${basedir}/queue/running
echo "Testing if finished jobs dir was created"
test -d ${basedir}/queue/finished

echo "Great, so far so good."

echo "Running with an empty queue"
timeout 2 ./process-build-queue.sh run

testjob=${basedir}/queue/new/testjob
echo "#!/bin/sh" > $testjob
echo "sleep 2" >> $testjob
echo "echo stdout stuff" >> $testjob
echo "echo stderr stuff >&2" >> $testjob
echo "echo it works > ${basedir}/foo" >> $testjob

echo "Running with an queue that only has non-executable stuff in it"
timeout 4 ./process-build-queue.sh run

echo "Checking that it didn't run"
! test -e ${basedir}/foo

echo "Checking that it is still in the incomding dir"
test -e $testjob

echo "Checking that the running dir is still empty"
test $(ls ${basedir}/queue/running | wc -l) -eq 0

echo "Checking that the finished dir is still empty"
test $(ls ${basedir}/queue/finished | wc -l) -eq 0

echo "Checking that the log dir is still empty"
test $(ls ${basedir}/logs | wc -l) -eq 0

chmod +x $testjob
echo "Running with a queue that has a job in it"
timeout 4 ./process-build-queue.sh run &

echo "Sleeping for a second to let the job get started"
sleep 1

echo "Checking that the incoming dir is empty now"
test $(ls ${basedir}/queue/new | wc -l) -eq 0

echo "Checking that the job is now in the running dir"
test $(ls ${basedir}/queue/running | wc -l) -eq 1

echo "Checking that the finished dir is still empty"
test $(ls ${basedir}/queue/finished | wc -l) -eq 0

echo "Sleeping another 2 seconds to let the job finish"
sleep 2

echo "Checking that the running dir is now empty"
test $(ls ${basedir}/queue/running | wc -l) -eq 0

echo "Checking that the finished dir now not empty"
test $(ls ${basedir}/queue/finished | wc -l) -eq 1

echo "Checking that the log dir now not empty"
test $(ls ${basedir}/logs | wc -l) -eq 1

echo "Checking that the file was created"
test $(ls ${basedir}/foo | wc -l) -eq 1

echo "Checking that stdout was captured"
grep stdout ${basedir}/logs/*

echo "Checking that stderr was captured"
grep stderr ${basedir}/logs/*
find ${basedir}
cat ${basedir}/logs/*

echo "Success"
