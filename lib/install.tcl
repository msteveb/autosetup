# Copyright (c) 2006-2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which can install autosetup

proc autosetup_install {} {
	if {[catch {
		file mkdir autosetup

		set f [open autosetup/autosetup w]

		set publicmodules {}

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
			foreach file [glob $::autosetup(libdir)/*.tcl] {
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
		foreach file {config.guess config.sub jimsh0.c find-tclsh test-tclsh LICENCE} {
			autosetup_install_file $::autosetup(dir)/$file autosetup
		}
		exec chmod 755 autosetup/config.sub autosetup/config.guess autosetup/find-tclsh

		writefile autosetup/README.autosetup "This is [autosetup_version]. See http://autosetup.workware.net.au/\n"

	} error]} {
		user-error "Failed to install autosetup: $error"
	}
	puts "Installed [autosetup_version] to autosetup/"
	catch {exec [info nameofexecutable] autosetup/autosetup --init} result
	puts $result

	exit 0
}

# Append the contents of $file to filehandle $f
proc autosetup_install_append {f file} {
	set in [open $file]
	puts $f [read $in]
	close $in
}

proc autosetup_install_file {file dir} {
	writefile [file join $dir [file tail $file]] [readfile $file]\n
}

if {$::autosetup(installed)} {
	user-error "autosetup can only be installed from development source, not from installed copy"
}
