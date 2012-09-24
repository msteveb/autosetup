# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module to help create auto.def and configure

proc autosetup_init {type} {
	set help 0
	if {$type in {? help}} {
		incr help
	} elseif {![dict exists $::autosetup(inittypes) $type]} {
		puts "Unknown type, --init=$type"
		incr help
	}
	if {$help} {
		puts "Use one of the following types (e.g. --init=make)\n"
		foreach type [lsort [dict keys $::autosetup(inittypes)]] {
			lassign [dict get $::autosetup(inittypes) $type] desc
			# XXX: Use the options-show code to wrap the description
			puts [format "%-10s %s" $type $desc]
		}
		exit 0
	}
	lassign [dict get $::autosetup(inittypes) $type] desc script

	puts "Initialising $type: $desc\n"

	# All initialisations happens in the top level srcdir
	cd $::autosetup(srcdir)

	uplevel #0 $script

	exit 0
}

proc autosetup_add_init_type {type desc script} {
	dict set ::autosetup(inittypes) $type [list $desc $script]
}

# This is for in creating build-system init scripts
#
# If the file doesn't exist, create it containing $contents
# If the file does exist, only overwrite if --force is specified.
#
proc autosetup_check_create {filename contents} {
	if {[file exists $filename]} {
		if {!$::autosetup(force)} {
			puts "I see $filename already exists."
			return
		} else {
			puts "I will overwrite the existing $filename because you used --force."
		}
	} else {
		puts "I don't see $filename, so I will create it."
	}
	writefile $filename $contents
}
