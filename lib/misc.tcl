# Copyright (c) 2007-2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module containing misc procs useful to modules
# Largely for platform compatibility

set autosetup(istcl) [info exists ::tcl_library]
set autosetup(iswin) [string equal windows $tcl_platform(platform)]

if {$autosetup(iswin)} {
	# mingw/windows separates $PATH with semicolons
	# and doesn't have an executable bit
	proc split-path {} {
		split [getenv PATH .] {;}
	}
	proc file-isexec {exec} {
		# Basic test for windows. We ignore .bat
		if {[file isfile $exec] || [file isfile $exec.exe]} {
			return 1
		}
		return 0
	}
} else {
	# unix separates $PATH with colons and has and executable bit
	proc split-path {} {
		split [getenv PATH .] :
	}
	# Check for an executable file
	proc file-isexec {exec} {
		if {[file executable $exec] && [file isfile $exec]} {
			return 1
		}
		return 0
	}
}

# Assume that exec can return stdout and stderr
proc exec-with-stderr {args} {
	exec {*}$args 2>@1
}

if {$autosetup(istcl)} {
	# Tcl doesn't have the env command
	proc getenv {name args} {
		if {[info exists ::env($name)]} {
			return $::env($name)
		}
		if {[llength $args]} {
			return [lindex $args 0]
		}
		return -code error "environment variable \"$name\" does not exist"
	}
	proc isatty? {channel} {
		dict exists [fconfigure $channel] -xchar
	}
	# Jim-compatible stacktrace using info frame
	proc stacktrace {} {
		set stacktrace {}
		# 2 to skip the current frame
		for {set i 2} {$i < [info frame]} {incr i} {
			set frame [info frame -$i]
			if {[dict exists $frame file]} {
				# We don't need proc, so use ""
				lappend stacktrace "" [dict get $frame file] [dict get $frame line]
			}
		}
		return $stacktrace
	}
} else {
	if {$autosetup(iswin)} {
		# On Windows, backslash convert all environment variables
		# (Assume that Tcl does this for us)
		proc getenv {name args} {
			string map {\\ /} [env $name {*}$args]
		}
	} else {
		# Jim on unix is simple
		alias getenv env
	}
	proc isatty? {channel} {
		set tty 0
		catch {
			# isatty is a recent addition to Jim Tcl
			set tty [$channel isatty]
		}
		return $tty
	}
}

# In case 'file normalize' doesn't exist
#
proc file-normalize {path} {
	if {[catch {file normalize $path} result]} {
		if {$path eq ""} {
			return ""
		}
		set oldpwd [pwd]
		if {[file isdir $path]} {
			cd $path
			set result [pwd]
		} else {
			cd [file dirname $path]
			set result [file join [pwd] [file tail $path]]
		}
		cd $oldpwd
	}
	return $result
}

# If everything is working properly, the only errors which occur
# should be generated in user code (e.g. auto.def).
# By default, we only want to show the error location in user code.
# We use [info frame] to achieve this, but it works differently on Tcl and Jim.
#
# This is designed to be called for incorrect usage in auto.def, via autosetup-error
#
proc error-location {msg} {
	if {$::autosetup(debug)} {
		return -code error $msg
	}
	# Search back through the stack trace for the first error in a .def file
	foreach {p f l} [stacktrace] {
		if {[string match *.def $f]} {
			return "[relative-path $f]:$l: Error: $msg"
		}
		#puts "Skipping $f:$l"
	}
	return $msg
}

# If everything is working properly, the only errors which occur
# should be generated in user code (e.g. auto.def).
# By default, we only want to show the error location in user code.
# We use [info frame] to achieve this, but it works differently on Tcl and Jim.
#
# This is designed to be called for incorrect usage in auto.def, via autosetup-error
#
proc error-stacktrace {msg} {
	if {$::autosetup(debug)} {
		return -code error $msg
	}
	# Search back through the stack trace for the first error in a .def file
	for {set i 1} {$i < [info level]} {incr i} {
		if {$::autosetup(istcl)} {
			array set info [info frame -$i]
		} else {
			lassign [info frame -$i] info(caller) info(file) info(line)
		}
		if {[string match *.def $info(file)]} {
			return "[relative-path $info(file)]:$info(line): Error: $msg"
		}
		#puts "Skipping $info(file):$info(line)"
	}
	return $msg
}

# Given the return from [catch {...} msg opts], returns an appropriate
# error message. A nice one for Jim and a less-nice one for Tcl.
# If 'fulltrace' is set, a full stack trace is provided.
# Otherwise a simple message is provided.
#
# This is designed for developer errors, e.g. in module code or auto.def code
#
#
proc error-dump {msg opts fulltrace} {
	if {$::autosetup(istcl)} {
		if {$fulltrace} {
			return "Error: [dict get $opts -errorinfo]"
		} else {
			return "Error: $msg"
		}
	} else {
		lassign $opts(-errorinfo) p f l
		if {$f ne ""} {
			set result "$f:$l: Error: "
		}
		append result "$msg\n"
		if {$fulltrace} {
			append result [stackdump $opts(-errorinfo)]
		}

		# Remove the trailing newline
		string trim $result
	}
}
