# Copyright (c) 2006 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Simple getopt module

# Parse everything out of the argv list which looks like an option
# Everything which doesn't look like an option, or is after --, is left unchanged
# Understands --enable-xxx and --with-xxx as synonyms for --xxx to enable the boolean option xxx.
# Understands --disable-xxx and --without-xxx to disable the boolean option xxx.
#
# The returned value is a dictionary keyed by option name
# Each value is a list of {type value} ... where type is "bool" or "str".
# The value for a boolean option is 0 or 1. The value of a string option is the value given.
proc getopt {argvname} {
	upvar $argvname argv
	set nargv {}

	set opts {}

	for {set i 0} {$i < [llength $argv]} {incr i} {
		set arg [lindex $argv $i]

		#dputs arg=$arg

		if {$arg eq "--"} {
			# End of options
			incr i
			lappend nargv {*}[lrange $argv $i end]
			break
		}

		if {[regexp {^--([^=][^=]+)=(.*)$} $arg -> name value]} {
			# --name=value
			dict lappend opts $name [list str $value]
		} elseif {[regexp {^--(enable-|disable-|with-|without-)?([^=]*)$} $arg -> prefix name]} {
			if {$prefix in {enable- with- ""}} {
				set value 1
			} else {
				set value 0
			}
			dict lappend opts $name [list bool $value]
		} else {
			lappend nargv $arg
		}
	}

	#puts "getopt: argv=[join $argv] => [join $nargv]"
	#array set getopt $opts
	#parray getopt

	set argv $nargv

	return $opts
}
