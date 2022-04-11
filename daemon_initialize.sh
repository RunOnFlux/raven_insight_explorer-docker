#!/usr/bin/env bash
#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WORNING="${RED}\xF0\x9F\x9A\xA8${NC}"


function tar_file_unpack()
{
    echo -e "${ARROW} ${YELLOW}Unpacking bootstrap archive file...${NC}"
    pv $1 | tar -zx -C $2
}

cd /root/
curl -sL https://deb.nodesource.com/setup_8.x | bash - > /dev/null 2>&1
apt-get install -y nodejs build-essential libzmq3-dev npm git > /dev/null 2>&1

DBDIR="/root/bitcore-node/bin"
if [ -d $DBDIR ]; then
  echo "Directory $DBDIR already exists, we will not download bootstrap. Use hard redeploy if you want to apply a new bootstrap."
else
  echo -e "${ARROW} ${YELLOW}Installing dependencies...${NC}"
  curl -sL https://deb.nodesource.com/setup_8.x | bash - > /dev/null 2>&1
  apt-get install -y nodejs build-essential libzmq3-dev npm git > /dev/null 2>&1

  #core-node
  cd /root/
  echo -e "${ARROW} ${YELLOW}Installing ravencore-node...${NC}"
  git clone https://github.com/RavenDevKit/ravencore-node.git > /dev/null 2>&1
  cd ravencore-node
  npm install > /dev/null 2>&1
  npm install https://github.com/traysi/x16rv2_hash/ > /dev/null 2>&1
  npm install https://github.com/traysi/kawpow-light-verifier/ > /dev/null 2>&1
  cd bin
  chmod +x ravencore-node
  ./ravencore-node create mynode > /dev/null 2>&1
  cd mynode
  rm ravencore-node.json
  echo -e "${ARROW} ${YELLOW}Creating bitcore-node config file...${NC}"

  if [[ "$DB_COMPONENT_NAME" == "" ]]; then
  echo -e "${ARROW} ${CYAN}Set default value of DB_COMPONENT_NAME as host...${NC}"
  DB_COMPONENT_NAME="fluxmongodb_raven_insight_explorer"
  else
  echo -e "${ARROW} ${CYAN}DB_COMPONENT_NAME as host is ${GREEN}${DB_COMPONENT_NAME}${NC}"
  fi

cat << EOF > ravencore-node.json
{
  "network": "livenet",
  "port": 3001,
  "services": [
    "ravend",
    "web",
    "insight-api",
    "insight-ui"
  ],
  "messageLog": "",
  "servicesConfig": {
    "web": {
      "disablePolling": false,
      "enableSocketRPC": true,
      "disableCors": true
    },
    "insight-ui": {
      "routePrefix": "",
      "apiPrefix": "api"
    },
    "insight-api": {
      "routePrefix": "api",
      "coinTicker" : "https://api.coinmarketcap.com/v1/ticker/ravencoin/?convert=USD",
      "coinShort": "RVN",
      "db": {
        "host": "${DB_COMPONENT_NAME}",
        "port": "27017",
        "database": "raven-api-livenet",
        "user": "test",
        "password": "test1234"
      }
    },
    "ravend": {
      "sendTxLog": "./data/pushtx.log",
      "spawn": {
        "datadir": "./data",
        "exec": "ravend",
        "rpcqueue": 1000,
        "rpcport": 8766,
        "zmqpubrawtx": "tcp://127.0.0.1:28332",
        "zmqpubhashblock": "tcp://127.0.0.1:28332",
        "rpcuser": "ravencoin",
        "rpcpassword": "local321"
      }
    }
  }
}
EOF

cd data
echo -e "${ARROW} ${YELLOW}Creating raven daemon config file...${NC}"
cat << EOF > raven.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
assetindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:28332
zmqpubhashblock=tcp://127.0.0.1:28332
rpcport=8766
rpcallowip=127.0.0.1
rpcuser=ravencoin
rpcpassword=local321
uacomment=ravencore-sl
mempoolexpiry=72
rpcworkqueue=1100
maxmempool=2000
dbcache=1000
maxtxfee=1.0
dbmaxfilesize=64
EOF

  cd /root/ravencore-node/bin/mynode/node_modules
  echo -e "${ARROW} ${YELLOW}Installing insight-api && insight-ui...${NC}"
  git clone https://github.com/RavenDevKit/insight-api.git > /dev/null 2>&1
  git clone https://github.com/RavenDevKit/insight-ui.git > /dev/null 2>&1
  cd insight-api
  npm install > /dev/null 2>&1
  cd ..
  cd insight-ui
  npm install > /dev/null 2>&1
fi

cd /root/ravencore-node/bin/mynode
while true; do
echo -e "${ARROW} ${YELLOW}Starting raven insight explorer...${NC}"
echo -e
../ravencore-node start
sleep 60
done
