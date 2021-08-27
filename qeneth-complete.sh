_nodes()
{
    local nodes

    [ -f topology.dot ] || return
    gvpr -V 2>/dev/null || return

    gvpr 'N [$.qn_console] { print($.name); }' topology.dot
}

_qeneth()
{
    local cur prev command module i

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ $COMP_CWORD -eq 1 ]] ; then
	COMPREPLY=($(compgen -W "generate status \
		    start stop restart console monitor link help" -- $cur))
    else
	command=${COMP_WORDS[1]}
	case $command in
	    start|stop|restart|console|monitor|link)
		COMPREPLY=($(compgen -W "$(_nodes)" -- $cur))
		;;
	esac
    fi
}

complete -F _qeneth qeneth
