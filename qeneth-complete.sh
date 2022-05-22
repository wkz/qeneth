_nodes()
{
    local nodes

    [ -f topology.dot ] || return
    gvpr -V 2>/dev/null || return

    gvpr 'N [$.qn_console] { print($.name); }' topology.dot
}

_links() {
    [ -f topology.dot ] || return
    gvpr -V 2>/dev/null || return

    gvpr '
        N [$.name == "'"$1"'"] {
            edge_t e;

            for (e = fstedge($); e; e = nxtedge(e, $)) {
                if (e.head == $)
                    printf("%s ", e.headport);
                else
                    printf("%s ", e.tailport);
            }

            printf("\n");
        }
	' topology.dot
}

_qeneth()
{
    local cur prev command module i

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $COMP_CWORD -eq 1 ]] ; then
	COMPREPLY=($(compgen -W "generate status web \
		    start stop restart console monitor link help" -- $cur))
    else
	command=${COMP_WORDS[1]}
	case $command in
	    link)
		if [ "$COMP_CWORD" -eq 2 ]; then
			COMPREPLY=($(compgen -W "$(_nodes)" -- $cur))
		elif [ "$COMP_CWORD" -eq 3 ]; then
			COMPREPLY=($(compgen -W "$(_links "$prev")" -- "$cur"))
		elif [ "$COMP_CWORD" -eq 4 ]; then
			COMPREPLY=($(compgen -W "on off" -- "$cur"))
		fi
		;;
	    start|stop|restart|console|monitor)
		COMPREPLY=($(compgen -W "$(_nodes)" -- $cur))
		;;
	esac
    fi
}

complete -F _qeneth qeneth
