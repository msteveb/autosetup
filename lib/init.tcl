# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module to help create auto.def and configure

proc autosetup_init {} {
	set create_configure 1
	if {[file exists configure]} {
		if {!$::autosetup(force)} {
			# Could this be an autosetup configure?
			if {![string match "*\nWRAPPER=*" [readfile configure]]} {
				puts "I see configure, but not created by autosetup, so I won't overwrite it."
				puts "Use autosetup --init --force to overwrite."
				set create_configure 0
			}
		} else {
			puts "I will overwrite the existing configure because you used --force."
		}
	} else {
		puts "I don't see configure, so I will create it."
	}
	if {$create_configure} {
		if {!$::autosetup(installed)} {
			user-notice "Warning: Initialising from the development version of autosetup"

			writefile configure "#!/bin/sh\nWRAPPER=\"\$0\" exec $::autosetup(dir)/autosetup \"\$@\"\n"
		} else {
			writefile configure \
{#!/bin/sh
dir="`dirname "$0"`/autosetup"
WRAPPER="$0" exec "`$dir/find-tclsh`" "$dir/autosetup" "$@"
}
		}
		catch {exec chmod 755 configure}
	}
	if {![file exists auto.def]} {
		puts "I don't see auto.def, so I will create a default one."
		writefile auto.def {# Initial auto.def created by 'autosetup --init'

use cc

# Add any user options here
options {
}

make-autoconf-h config.h
make-template Makefile.in
}
	}
	if {![file exists Makefile.in]} {
		puts "Note: I don't see Makefile.in. You will probably need to create one."
	}

	exit 0
}
