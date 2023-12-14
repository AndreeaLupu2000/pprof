#  Copyright 2017 Google Inc. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


#!/usr/bin/env bash

set -e
set -x
MODE=atomic
echo "mode: $MODE" > coverage.txt

if [ "$RUN_STATICCHECK" != "false" ]; then
  staticcheck ./...
fi

# Packages that have any tests.
PKG=$(go list -f '{{if .TestGoFiles}} {{.ImportPath}} {{end}}' ./...)

go test -v $PKG

for d in $PKG; do
  go test -race -coverprofile=profile.out -covermode=$MODE $d
  if [ -f profile.out ]; then
    cat profile.out | grep -v "^mode: " >> coverage.txt
    rm profile.out
  fi
done

go vet -all ./...
if [ "$RUN_GOLANGCI_LINTER" != "false" ];  then
  golangci-lint run -D errcheck --timeout=3m ./...  # TODO: Enable errcheck back.
fi

gofmt -s -d .

#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"

done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"

done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"

done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"

done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"

done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
/usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
#!/bin/bash

echo "**************************************************************** Start script ************************************************************"
n=$1
port=$2
CONFIG=$3
echo " "

list_descendants()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}

echo "start aes"
#
for ((i=1;i<=$n;i++))do
/usr/bin/time -o TIME/Server/time_client_aes_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/server/n$n/aes/profile_server$i" server --port $port -qlog "qlog/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
# /usr/bin/time -o time_client_aes_${CONFIG}.txt -a
./qperf-go --cpu-profile "pprof/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
# shellcheck disable=SC2034
/usr/bin/time -o TIME/Server/time_client_noAES_${CONFIG}.txt -a  ./qperf-go --cpu-profile "pprof/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
# /usr/bin/time -o time_client_noAES_${CONFIG}.txt -a
./qperf-go --cpu-profile "pprof/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"

echo " "

echo "start chacha20"
for ((i=1;i<=$n;i++))do
/usr/bin/time -o TIME/Server/time_client_chacha20_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
# /usr/bin/time -o time_client_chacha20_${CONFIG}.txt -a
./qperf-go --cpu-profile "pprof/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl  -cs chacha20
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "***************************** Start XADS ***************************"

echo " "

echo "start aes"
for ((i=1;i<=$n;i++))do
/usr/bin/time -o TIME/Server/time_client_aes_xads_${CONFIG}.txt -a  ./qperf-go --cpu-profile "pprof/XADS/server/n$n/aes/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/aes/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
# /usr/bin/time -o time_client_aes_xads_${CONFIG}.txt -a
./qperf-go --cpu-profile "pprof/XADS/client/n$n/aes/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/aes/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish aes"

echo " "

echo "start noAES"
for ((i=1;i<=$n;i++))do
/usr/bin/time -o TIME/Server/time_client_noAES_xads_${CONFIG}.txt -a ./qperf-go --cpu-profile "pprof/XADS/server/n$n/noAES/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/noAES/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
# /usr/bin/time -o time_client_noAES_xads_${CONFIG}.txt -a
./qperf-go --cpu-profile "pprof/XADS/client/n$n/noAES/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/noAES/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs aes_128 -gcm -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish noAES"
echo " "
echo "start chacha20"
for ((i=1;i<=$n;i++))do
/usr/bin/time -o TIME/Server/time_client_chacha20_${CONFIG}.txt -a  ./qperf-go --cpu-profile "pprof/XADS/server/n$n/chacha20/profile_server$i" server -port $port -qlog "qlog/XADS/server/n$n/chacha20/server_${i}_qlog_{odcid}.qlog" -qlog-level info -tls-cert server.crt -tls-key server.key & QPERF_PID=$!
# /usr/bin/time -o time_client_chacha20_xads_${CONFIG}.txt -a
./qperf-go --cpu-profile "pprof/XADS/client/n$n/chacha20/profile_client$i" client -a localhost:$port -qlog "qlog/XADS/client/n$n/chacha20/client_${i}_qlog_{odcid}.qlog" -qlog-level info -cert-pool server.crt -pl -cs chacha20 -xads
kill $(list_descendants $QPERF_PID)
done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"

done
echo "finish chacha20"

echo " "

echo "************************* Done XADS ******************************"

echo "******************************************************************* Done script *****************************************************************"
