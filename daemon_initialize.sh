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


PATH_BIN="root"

function extract_file() {

    local extraction_dir="./"
    if [ -n "$2" ]; then
        extraction_dir="$2"
    fi

    if [[ $1 =~ .*zip$ ]]; then
        unzip $1 -d ${extraction_dir} > /dev/null 2>&1 || return 1
    elif [[ $1 =~ .*tar.gz$ ]]; then
        tar zxf $1 -C ${extraction_dir} > /dev/null 2>&1 || return 1
    fi

    return 0
}

function update_daemon(){

 DOWN_URL=$(curl --silent "https://api.github.com/repos/RavenProject/Ravencoin/releases/latest" | jq -r '.assets[] | .browser_download_url' | grep -e ".*x86.*disable-wallet.*")
 VERSION=$(curl --silent "https://api.github.com/repos/RavenProject/Ravencoin/releases/latest" | jq -r .tag_name)

if [[ ! -f /$PATH_BIN/.ravencore/ravencore-node/bin/version.json ]]; then
 echo -e "${ARROW} ${YELLOW}Installing raven daemon...${NC}"
 wget  --tries=5 $DOWN_URL -P /$PATH_BIN/.ravencore/ravencore-node/bin/tmp > /dev/null 2>&1
 zip_file="${DOWN_URL##*/}"
 jq -n --arg version $VERSION  '{"version":"\($version)"}' > /$PATH_BIN/.ravencore/ravencore-node/bin/version.json
 cd /$PATH_BIN/.ravencore/ravencore-node/bin/tmp
 extract_file ${zip_file}
 local targz_file=$(find ./linux-disable-wallet/ -type f -name '*.tar.gz' 2>/dev/null)
 extract_file ${targz_file}
 mv $(find . -type d -name 'raven*' 2>/dev/null)/bin/raven* /usr/local/bin
 chmod +x /usr/local/bin/ravend > /dev/null 2>&1
 chmod +x /usr/local/bin/raven-cli > /dev/null 2>&1
 rm /$PATH_BIN/.ravencore/ravencore-node/bin/ravend > /dev/null 2>&1
 rm /$PATH_BIN/.ravencore/ravencore-node/bin/raven-cli > /dev/null 2>&1
 cp /usr/local/bin/ravend /$PATH_BIN/.ravencore/ravencore-node/bin/ravend > /dev/null 2>&1
 cp /usr/local/bin/raven-cli /$PATH_BIN/.ravencore/ravencore-node/bin/raven-cli > /dev/null 2>&1
 chmod +x /$PATH_BIN/.ravencore/ravencore-node/bin/raven-cli > /dev/null 2>&1
 chmod +x /$PATH_BIN/.ravencore/ravencore-node/bin/ravend > /dev/null 2>&1
 cd /$PATH_BIN/.ravencore/ravencore-node/bin
 rm -rf /$PATH_BIN/.ravencore/ravencore-node/bin/tmp > /dev/null 2>&1

else

   echo -e "${ARROW} ${YELLOW}Checking daemon update...${NC}"
   local_version=$(jq -r .version /$PATH_BIN/.ravencore/ravencore-node/bin/version.json)
   echo -e "${ARROW} ${YELLOW}Local: ${GREEN}$local_version${YELLOW}, Remote: ${GREEN}$VERSION ${NC}"

  if [[ "$VERSION" != "" && "$local_version" != "$VERSION" ]]; then

   echo -e "${ARROW} ${YELLOW}New version detected: ${GREEN}$VERSION ${NC}"
   wget  --tries=5 $DOWN_URL -P /$PATH_BIN/.ravencore/ravencore-node/bin/tmp > /dev/null 2>&1
   zip_file="${DOWN_URL##*/}"
   rm /$PATH_BIN/.ravencore/ravencore-node/bin/version.json
   jq -n --arg version $VERSION  '{"version":"\($version)"}' > /$PATH_BIN/.ravencore/ravencore-node/bin/version.json
   cd /$PATH_BIN/.ravencore/ravencore-node/bin/tmp
   extract_file ${zip_file}
   local targz_file=$(find ./linux-disable-wallet/ -type f -name '*.tar.gz' 2>/dev/null)
   extract_file ${targz_file}
   mv $(find . -type d -name 'raven*' 2>/dev/null)/bin/raven* /usr/local/bin
   chmod +x /usr/local/bin/ravend > /dev/null 2>&1
   chmod +x /usr/local/bin/raven-cli > /dev/null 2>&1
   rm /$PATH_BIN/.ravencore/ravencore-node/bin/ravend > /dev/null 2>&1
   rm /$PATH_BIN/.ravencore/ravencore-node/bin/raven-cli > /dev/null 2>&1
   cp /usr/local/bin/ravend /$PATH_BIN/.ravencore/ravencore-node/bin/ravend > /dev/null 2>&1
   cp /usr/local/bin/raven-cli /$PATH_BIN/.ravencore/ravencore-node/bin/raven-cli > /dev/null 2>&1
   chmod +x /$PATH_BIN/.ravencore/ravencore-node/bin/raven-cli > /dev/null 2>&1
   chmod +x /$PATH_BIN/.ravencore/ravencore-node/bin/ravend > /dev/null 2>&1
   cd /$PATH_BIN/.ravencore/ravencore-node/bin
   rm -rf /$PATH_BIN/.ravencore/ravencore-node/bin/tmp > /dev/null 2>&1

  fi
fi

}

cd /root/
echo -e ""
echo -e "${ARROW} ${YELLOW}Installing dependencies...${NC}"
curl -sL https://deb.nodesource.com/setup_8.x | bash - > /dev/null 2>&1
apt-get install -y nodejs build-essential libzmq3-dev npm git > /dev/null 2>&1

DDIR="/root/.ravencore/ravencore-node/bin"
if [ -d $DDIR ]; then
  echo -e "${ARROW} ${YELLOW}Ravencore-node already installed...${NC}"
else
  #core-node
  mkdir -p /root/.ravencore > /dev/null 2>&1
  cd /root/.ravencore
  echo -e "${ARROW} ${YELLOW}Installing ravencore-node...${NC}"
  git clone https://github.com/RavenDevKit/ravencore-node.git > /dev/null 2>&1
  cd ravencore-node
  npm install > /dev/null 2>&1
  npm install https://github.com/traysi/x16rv2_hash/ > /dev/null 2>&1
  npm install https://github.com/traysi/kawpow-light-verifier/ > /dev/null 2>&1
  npm install node-x16r > /dev/null 2>&1
  cd bin
  chmod +x ravencore-node
  ./ravencore-node create mynode > /dev/null 2>&1
  cd mynode
  rm ravencore-node.json > /dev/null 2>&1
  echo -e "${ARROW} ${YELLOW}Creating bitcore-node config file...${NC}"

  if [[ "$DB_COMPONENT_NAME" == "" ]]; then
  echo -e "${ARROW} ${CYAN}Set default value of DB_COMPONENT_NAME${NC}"
  DB_COMPONENT_NAME="fluxmongodb_raven_insight_explorer"
  else
  echo -e "${ARROW} ${CYAN}DB_COMPONENT_NAME as host is ${GREEN}${DB_COMPONENT_NAME}${NC}"
  fi

mkdir -P /root/.ravencore > /dev/null 2>&1
rm /root/.ravencore/ravencore-node.json > /dev/null 2>&1

cat << EOF > /root/.ravencore/ravencore-node.json
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
        "user": "",
        "password": ""
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
mkdir /root/.ravencore/data > /dev/null 2>&1
rm /root/.ravencore/data/raven.conf > /dev/null 2>&1
echo -e "${ARROW} ${YELLOW}Creating raven daemon config file...${NC}"
cat << EOF > /root/.ravencore/data/raven.conf
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

  cd /root/.ravencore/ravencore-node/node_modules
  echo -e "${ARROW} ${YELLOW}Installing insight-api && insight-ui...${NC}"
  git clone https://github.com/RavenDevKit/insight-api.git > /dev/null 2>&1
  git clone https://github.com/RavenDevKit/insight-ui.git > /dev/null 2>&1
  cd insight-api
  npm install > /dev/null 2>&1
  cd ..
  cd insight-ui
  npm install > /dev/null 2>&1
fi

update_daemon
cd /root/.ravencore/ravencore-node/bin/mynode
while true; do
echo -e "${ARROW} ${YELLOW}Starting raven insight explorer...${NC}"
echo -e ""
../ravencore-node start
sleep 60
done
