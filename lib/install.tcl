# Copyright (c) 2006-2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which can install autosetup

proc autosetup_install {dir} {
	if {[catch {
		cd $dir
		file mkdir autosetup

		set f [open autosetup/autosetup w]

		set publicmodules $::autosetup(libdir)/default.auto

		# First the main script, but only up until "CUT HERE"
		set in [open $::autosetup(dir)/autosetup]
		while {[gets $in buf] >= 0} {
			if {$buf ne "##-- CUT HERE --##"} {
				puts $f $buf
				continue
			}

			# Insert the static modules here
			# i.e. those which don't contain @synopsis:
			puts $f "set autosetup(installed) 1"
			foreach file [lsort [glob $::autosetup(libdir)/*.tcl]] {
				set buf [readfile $file]
				if {[string match "*\n# @synopsis:*" $buf]} {
					lappend publicmodules $file
					continue
				}
				set modname [file rootname [file tail $file]]
				puts $f "# ----- module $modname -----"
				puts $f "\nset modsource($modname) \{"
				puts $f $buf
				puts $f "\}\n"
			}
		}
		close $in
		close $f
		exec chmod 755 autosetup/autosetup

		# Install public modules
		foreach file $publicmodules {
			autosetup_install_file $file autosetup
		}

		# Install support files
		foreach file {config.guess config.sub jimsh0.c find-tclsh test-tclsh LICENSE} {
			autosetup_install_file $::autosetup(dir)/$file autosetup
		}
		exec chmod 755 autosetup/config.sub autosetup/config.guess autosetup/find-tclsh

		writefile autosetup/README.autosetup \
			"This is [autosetup_version]. See http://msteveb.github.com/autosetup/\n"

	} error]} {
		user-error "Failed to install autosetup: $error"
	}
	puts "Installed [autosetup_version] to autosetup/"

	# Now create 'configure' if necessary
	autosetup_create_configure

	exit 0
}

proc autosetup_create_configure {} {
	if {[file exists configure]} {
		if {!$::autosetup(force)} {
			# Could this be an autosetup configure?
			if {![string match "*\nWRAPPER=*" [readfile configure]]} {
				puts "I see configure, but not created by autosetup, so I won't overwrite it."
				puts "Remove it or use --force to overwrite."
				return
			}
		} else {
			puts "I will overwrite the existing configure because you used --force."
		}
	} else {
		puts "I don't see configure, so I will create it."
	}
	writefile configure \
{#!/bin/sh
dir="`dirname "$0"`/autosetup"
WRAPPER="$0"; export WRAPPER; exec "`$dir/find-tclsh`" "$dir/autosetup" "$@"
}
	catch {exec chmod 755 configure}
}

# Append the contents of $file to filehandle $f
proc autosetup_install_append {f file} {
	set in [open $file]
	puts $f [read $in]
	close $in
}

proc autosetup_install_file {file dir} {
	if {![file exists $file]} {
		error "Missing installation file '$file'"
	}
	writefile [file join $dir [file tail $file]] [readfile $file]\n
}

if {$::autosetup(installed)} {
	user-error "autosetup can only be installed from development source, not from installed copy"
}
