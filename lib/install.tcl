# Copyright (c) 2006-2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which can install autosetup

# autosetup(installed)=1 means that autosetup is not running from source
# autosetup(sysinstall)=1 means that autosetup is running from a sysinstall verion
# shared=1 means that we are trying to do a sysinstall. This is only possible from the development source.

proc autosetup_install {dir {shared 0}} {
	global autosetup
	if {$shared} {
		if {$autosetup(installed) || $autosetup(sysinstall)} {
			user-error "Can only --sysinstall from development sources"
		}
	} elseif {$autosetup(installed) && !$autosetup(sysinstall)} {
		user-error "Can't --install from project install"
	}

	if {$autosetup(sysinstall)} {
		# This is the sysinstall version, so install just uses references
		cd $dir

		puts "[autosetup_version] creating configure to use system-installed autosetup"
		autosetup_create_configure 1
		puts "Creating autosetup/README.autosetup"
		file mkdir autosetup
		autosetup_install_readme autosetup/README.autosetup 1
		return
	}

	if {[catch {
		if {$shared} {
			set target $dir/bin/autosetup
			set installedas $target
		} else {
			if {$dir eq "."} {
				set installedas autosetup
			} else {
				set installedas $dir/autosetup
			}
			cd $dir
			file mkdir autosetup
			set target autosetup/autosetup
		}
		set targetdir [file dirname $target]
		file mkdir $targetdir

		set f [open $target w]

		set publicmodules {}

		# First the main script, but only up until "CUT HERE"
		set in [open $autosetup(dir)/autosetup]
		while {[gets $in buf] >= 0} {
			if {$buf ne "##-- CUT HERE --##"} {
				puts $f $buf
				continue
			}

			# Insert the static modules here
			# i.e. those which don't contain @synopsis:
			# All modules are inserted if $shared is set
			puts $f "set autosetup(installed) 1"
			puts $f "set autosetup(sysinstall) $shared"
			foreach file [lsort [glob $autosetup(libdir)/*.{tcl,auto}]] {
				set modname [file tail $file]
				set ext [file ext $modname]
				set buf [readfile $file]
				if {!$shared} {
					if {$ext eq ".auto" || [string match "*\n# @synopsis:*" $buf]} {
						lappend publicmodules $file
						continue
					}
				}
				dputs "install: importing lib/[file tail $file]"
				puts $f "# ----- @module $modname -----"
				puts $f "\nset modsource($modname) \{"
				puts $f $buf
				puts $f "\}\n"
			}
			if {$shared} {
				foreach {srcname destname} [list $autosetup(libdir)/README.autosetup-lib README.autosetup \
						$autosetup(srcdir)/LICENSE LICENSE] {
					dputs "install: importing $srcname as $destname"
					puts $f "\nset modsource($destname) \\\n[list [readfile $srcname]\n]\n"
				}
			}
		}
		close $in
		close $f
		catch {exec chmod 755 $target}

		set installfiles {autosetup-config.guess autosetup-config.sub autosetup-test-tclsh}
		set removefiles {}

		if {!$shared} {
			autosetup_install_readme $targetdir/README.autosetup 0

			# Install public modules
			foreach file $publicmodules {
				set tail [file tail $file]
				autosetup_install_file $file $targetdir/$tail
			}
			lappend installfiles jimsh0.c autosetup-find-tclsh LICENSE
			lappend removefiles config.guess config.sub test-tclsh find-tclsh
		} else {
			lappend installfiles {sys-find-tclsh autosetup-find-tclsh}
		}

		# Install support files
		foreach fileinfo $installfiles {
			if {[llength $fileinfo] == 2} {
				lassign $fileinfo source dest
			} else {
				lassign $fileinfo source
				set dest $source
			}
			autosetup_install_file $autosetup(dir)/$source $targetdir/$dest
		}

		# Remove obsolete files
		foreach file $removefiles {
			if {[file exists $targetdir/$file]} {
				file delete $targetdir/$file
			}
		}
	} error]} {
		user-error "Failed to install autosetup: $error"
	}
	if {$shared} {
		set type "system"
	} else {
		set type "local"
	}
	puts "Installed $type [autosetup_version] to $installedas"

	if {!$shared} {
		# Now create 'configure' if necessary
		autosetup_create_configure 0
	}
}

proc autosetup_create_configure {shared} {
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
	if {$shared} {
		writefile configure \
{#!/bin/sh
WRAPPER="$0"; export WRAPPER; "autosetup" "$@"
}
	} else {
		writefile configure \
{#!/bin/sh
dir="`dirname "$0"`/autosetup"
WRAPPER="$0"; export WRAPPER; exec "`"$dir/autosetup-find-tclsh"`" "$dir/autosetup" "$@"
}
	}
	catch {exec chmod 755 configure}
}

# Append the contents of $file to filehandle $f
proc autosetup_install_append {f file} {
	dputs "install: include $file"
	set in [open $file]
	puts $f [read $in]
	close $in
}

proc autosetup_install_file {source target} {
	dputs "install: $source => $target"
	if {![file exists $source]} {
		error "Missing installation file '$source'"
	}
	writefile $target [readfile $source]\n
	# If possible, copy the file mode
	file stat $source stat
	set mode [format %o [expr {$stat(mode) & 0x1ff}]]
	catch {exec chmod $mode $target}
}

proc autosetup_install_readme {target sysinstall} {
	set readme "README.autosetup created by [autosetup_version]\n\n"
	if {$sysinstall} {
		append readme \
{This is the autosetup directory for a system install of autosetup.
Loadable modules can be added here.
}
	} else {
		append readme \
{This is the autosetup directory for a local install of autosetup.
It contains autosetup, support files and loadable modules.
}
}

	append readme {
*.tcl files in this directory are optional modules which
can be loaded with the 'use' directive.

*.auto files in this directory are auto-loaded.

For more information, see http://msteveb.github.com/autosetup/
}
	dputs "install: autosetup/README.autosetup"
	writefile $target $readme
}
