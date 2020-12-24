#!/bin/bash

# Default Parameters
clis_path=/opt/bin/
configs_path=$HOME
max_allowed_last_block_age=1800 # 30 Minutes expressed in seconds


coin="$1";

if [ -z $coin ]; then
        /bin/echo "ERR: No coin selected. Usage example 'syncstate bitcoin'";
        exit 1;
fi
coin_cli="${clis_path}${coin}-cli"

if [ ! -f ${coin_cli} ]; then
    echo "ERR: The selected coin is not available or you should modify the clis_path variable"
    exit 2
fi

coin_cli="${coin_cli} -conf=${configs_path}/.${coin}/${coin}.conf"

count=$(${coin_cli} getblockcount);

RESULT=$?
if [ $RESULT != 0 ]; then
  echo "ERR: The cli does not seem to be available. Maybe the node is not running or rpc is not enabled?"
  exit 3
fi


hash=$(${coin_cli} getblockhash $count);

t=$(${coin_cli} getblock "$hash" | grep '"time"' | awk '{print $2}' | sed -e 's/,$//g');



cur_t=$(date +%s);
diff_t=$[$cur_t - $t];
if (( $diff_t <= max_allowed_last_block_age )); then
        echo ""
        echo "${coin} is in synch. Last block is ${diff_t} seconds old."
        echo ""
else
        echo "WARNING:"
        echo "${coin} node could be NOT in synch. Details:"
        echo "Last block hash: $hash";
        echo "Last block timestamp is: $t";
        echo "Last block count: $count";
        echo -n "Last synched ${coin} block is: ";
        echo $diff_t | /usr/bin/awk '{printf "%ddays %dhours %dminutes %dseconds old\n",$1/(60*60*24),$1/(60*60)%24,$1%(60*60)/60,$1%60}';
        echo ""
fi
