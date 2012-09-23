# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module to help create auto.def and configure

proc autosetup_init {} {
	if {![file exists auto.def]} {
		puts "I don't see auto.def, so I will create a default one."
		writefile auto.def {# Initial auto.def created by 'autosetup --init'

use cc

# Add any user options here
options {
}

make-config-header config.h
make-template Makefile.in
}
	}
	if {![file exists Makefile.in]} {
		puts "Note: I don't see Makefile.in. You will probably need to create one."
	}

	exit 0
}
