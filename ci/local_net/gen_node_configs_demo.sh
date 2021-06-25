#!/bin/bash

# Generates configurations for 4 nodes. Mostly the same script as `gen_$NODE_CONFIGS_DIR.sh` but discribes
# the real life flow (keys don't leave the place where they are generated).

set -euox pipefail

CHAIN_ID="verim"
NODE_CONFIGS_DIR="node_configs"

rm -rf $NODE_CONFIGS_DIR
mkdir $NODE_CONFIGS_DIR

# sed in macos requires extra argument
extension=''
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    extension=''
elif [[ "$OSTYPE" == "darwin"* ]]; then
    extension='.orig'
fi


echo "################################ Jack's node0"

NODE_0_HOME="node_configs/node0"

echo "# Generate key"
verim-noded keys add jack --home $NODE_0_HOME

echo "# Initialze node"
verim-noded init node0 --chain-id $CHAIN_ID --home $NODE_0_HOME

echo "# Add genesis account"
verim-noded add-genesis-account jack 10000000token,100000000stake --home $NODE_0_HOME

echo "# Generate genesis node tx"
verim-noded gentx jack 1000000stake --chain-id $CHAIN_ID --home $NODE_0_HOME

echo "# Publish validator pubkey"
NODE_0_ID=$(verim-noded tendermint show-node-id --home $NODE_0_HOME)

echo "# Make RPC enpoint available externally (optional, allows cliens to connect to the node)"
sed -i $extension 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' $NODE_0_HOME/config/config.toml


echo "################################ Alice's node1"

NODE_1_HOME="$NODE_CONFIGS_DIR/node1"

echo "# Generate key"
verim-noded keys add alice --home $NODE_1_HOME

echo "# Initialze node"
verim-noded init node1 --chain-id $CHAIN_ID --home $NODE_1_HOME

echo "### Get genesis from Jack"
cp $NODE_0_HOME/config/genesis.json $NODE_1_HOME/config

echo "### Get genesis node txs form Jack"
mkdir $NODE_1_HOME/config/gentx
cp $NODE_0_HOME/config/gentx/* $NODE_1_HOME/config/gentx

echo "# Add genesis account"
verim-noded add-genesis-account alice 10000000token,100000000stake --home $NODE_1_HOME

echo "# Generate genesis node tx"
verim-noded gentx alice 1000000stake --chain-id $CHAIN_ID --home $NODE_1_HOME

echo "# Publish validator pubkey"
NODE_1_ID=$(verim-noded tendermint show-node-id --home $NODE_1_HOME)

echo "# Make RPC enpoint available externally (optional, allows cliens to connect to the node)"
sed -i $extension 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' $NODE_1_HOME/config/config.toml


echo "################################ Bob's node2"

NODE_2_HOME="$NODE_CONFIGS_DIR/node2"

echo "# Generate key"
verim-noded keys add bob --home $NODE_2_HOME

echo "# Initialze node"
verim-noded init node2 --chain-id $CHAIN_ID --home $NODE_2_HOME

echo "### Get genesis from Alice"
cp $NODE_1_HOME/config/genesis.json $NODE_2_HOME/config

echo "### Get genesis node txs form Alice"
mkdir $NODE_2_HOME/config/gentx
cp $NODE_1_HOME/config/gentx/* $NODE_2_HOME/config/gentx

echo "# Add genesis account"
verim-noded add-genesis-account bob 10000000token,100000000stake --home $NODE_2_HOME

echo "# Generate genesis node tx"
verim-noded gentx bob 1000000stake --chain-id $CHAIN_ID --home $NODE_2_HOME

echo "# Publish validator pubkey"
NODE_2_ID=$(verim-noded tendermint show-node-id --home $NODE_2_HOME)

echo "# Make RPC enpoint available externally (optional, allows cliens to connect to the node)"
sed -i $extension 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' $NODE_2_HOME/config/config.toml


echo "################################ Anna's node3"

NODE_3_HOME="$NODE_CONFIGS_DIR/node3"

echo "# Generate key"
verim-noded keys add anna --home $NODE_3_HOME

echo "# Initialze node"
verim-noded init node3 --chain-id $CHAIN_ID --home $NODE_3_HOME

echo "### Get genesis from Bob"
cp $NODE_2_HOME/config/genesis.json $NODE_3_HOME/config

echo "### Get genesis node txs form Bob"
mkdir $NODE_3_HOME/config/gentx
cp $NODE_2_HOME/config/gentx/* $NODE_3_HOME/config/gentx

echo "# Add genesis account"
verim-noded add-genesis-account anna 10000000token,100000000stake --home $NODE_3_HOME

echo "# Generate genesis node tx"
verim-noded gentx anna 1000000stake --chain-id $CHAIN_ID --home $NODE_3_HOME

echo "# Publish validator pubkey"
NODE_3_ID=$(verim-noded tendermint show-node-id --home $NODE_3_HOME)

echo "# Make RPC enpoint available externally (optional, allows cliens to connect to the node)"
sed -i $extension 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' $NODE_3_HOME/config/config.toml


echo "################################ Anna (last participatn) shares genesis with everyone else"

echo "# Add genesis node txs into genesis"
verim-noded collect-gentxs --home $NODE_3_HOME

echo "# Verify genesis"
verim-noded validate-genesis --home $NODE_3_HOME

cp $NODE_3_HOME/config/genesis.json $NODE_0_HOME/config/
cp $NODE_3_HOME/config/genesis.json $NODE_1_HOME/config/
cp $NODE_3_HOME/config/genesis.json $NODE_2_HOME/config/
