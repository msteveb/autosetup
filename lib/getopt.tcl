# Copyright (c) 2006 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Simple getopt module

# Parse everything out of the argv list which looks like an option
# Knows about --enable-thing and --disable-thing as alternatives for --thing=0 or --thing=1
# Everything which doesn't look like an option, or is after --, is left unchanged
#
proc getopt {argvname} {
	upvar $argvname argv
	set nargv {}

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
			lappend opts($name) $value
		} elseif {[regexp {^--(enable-|disable-)?([^=]*)$} $arg -> prefix name]} {
			if {$prefix eq "disable-"} {
				set value 0
			} else {
				set value 1
			}
			lappend opts($name) $value
		} else {
			lappend nargv $arg
		}
	}

	#puts "getopt: argv=[join $argv] => [join $nargv]"
	#parray opts

	set argv $nargv

	return [array get opts]
}

proc opt_val {optarrayname options {default {}}} {
	upvar $optarrayname opts

	set result {}

	foreach o $options {
		if {[info exists opts($o)]} {
			lappend result {*}$opts($o)
		}
	}
	if {[llength $result] == 0} {
		return $default
	}
	return $result
}

proc opt_bool {optarrayname args} {
	upvar $optarrayname opts

	# Support the args being passed as a list
	if {[llength $args] == 1} {
		set args [lindex $args 0]
	}

	foreach o $args {
		if {[info exists opts($o)]} {
			# For boolean options, the last value wins
			if {[lindex $opts($o) end] in {"1" "yes"}} {
				return 1
			}
		}
	}
	return 0
}
