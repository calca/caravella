#!/bin/sh
# Cold start to Home ready, in ms: Android's launch splash stays until Home
# is drawn with its groups (homeReady), so `am start -W` TotalTime measures
# exactly that. One warm-up start, then N measured ones; prints each and
# the median. See tool/perf/README.md.
#
#   tool/perf/cold_start.sh <device> <apk> [runs]
set -eu
device=$1
apk=$2
runs=${3:-6}
package=io.caravella.egm.dev
activity=$package/io.caravella.egm.MainActivity

adb -s "$device" install -r "$apk" >/dev/null
adb -s "$device" shell am start -W -S -n "$activity" >/dev/null
sleep 4
times=""
i=0
while [ "$i" -lt "$runs" ]; do
  t=$(adb -s "$device" shell am start -W -S -n "$activity" | awk '/TotalTime/ {print $2}' | tr -d '\r')
  echo "$t"
  times="$times $t"
  i=$((i + 1))
  sleep 3
done
echo "$times" | tr ' ' '\n' | grep . | sort -n | awk '{a[NR]=$1} END {m = (NR % 2) ? a[(NR+1)/2] : (a[NR/2] + a[NR/2+1]) / 2; print "median " m " ms (" NR " runs)"}'
