###############################################################################
#                              Command Management                             #
###############################################################################

function colorText { echo $(tput setaf 2)"$@"$(tput sgr0); }

function printCommand {
    cmd=$1
    while [ ${#cmd} -lt 15 ]; do cmd+="~"; done
    echo "$cmd""-->"
}

function fill {
    size=$1
    addition=''
    while [ $size -lt $2 ]; do addition+=$3; size=$(($size + 1)); done
    echo "$addition"
}

function getKey {
    echo "$@" | sed 's/^\((.*)\).*$/\1/'
}
function getCmd {
    echo "$@" | sed 's/^(.*)\(.*\)/\1/'
}

function printCommands {
    commands="$(cat $savedCommands)"

    longest=$(printf "$commands" | while read line; do k=$(getKey $line); echo ${#k}; done | sort -n | tail -n 1)
    printf "$commands\n" | \
	while read cmdline; do
	    key=$(getKey "$cmdline")
	    cmd=$(getCmd "$cmdline")
	    echo ${#key} $key $cmd
	done | sort -n | awk '{$1=""; print $0}' |

	while read cmdline; do
	    key=$(getKey "$cmdline")
	    cmd=$(getCmd "$cmdline")
	    echo "$(fill ${#key} $(($longest + 1)) ' ')("$(colorText "${key:1:$((${#key} - 2))}")")" "-->" $cmd 1>&2
	done
}

function listCommands {
    printf "$(printCommands)" 1>&2
}

function deleteCommand {
    newCommands="$(cat $savedCommands | grep -v -e '^('$1')')"
    printf "$newCommands\n" > $savedCommands
}

# if it has a flag
if [[ $1 != '' && ${1::1} == '-' ]]; then
    case $1 in
	'-s') deleteCommand $2
	      echo "($2) ${@:3}" >> $savedCommands
	      ;;
	'-d') deleteCommand ${@:2};;
	'-l') printCommands;;
	*) echo "commands: " 1>&2
	   echo "   set:    -s <name> <command>" 1>&2
	   echo "   delete: -d <name>" 1>&2
	   echo "   list:   -l" 1>&2
	   echo "   help:   -h" 1>&2;;
    esac
else
    getCmd $(cat $savedCommands | grep -e "^($1)")
fi