# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# @synopsis:
#
# This module supports checking various 'features' of the C
# compiler/linker environment. Common commands are cc-check-includes,
# cc-check-types, cc-check-functions, make-autoconf-h and make-template.

# "=Module Options: cc"
module-options {
	host:host-alias =>		{a complete or partial cpu-vendor-opsys for the system where
							the application will run (defaults to the same value as --build)}
	build:build-alias =>	{a complete or partial cpu-vendor-opsys for the system
							where the application will be built (defaults to the
							result of running config.guess)}
	prefix:dir =>			{the target directory for the build (defaults to /usr/local)}
}


# Returns 1 if exists, or 0 if  not
#
proc check-feature {name code} {
	msg-checking "Checking for $name..."
	set r [uplevel 1 $code]
	define-feature $name $r
	if {$r} {
		msg-result "ok"
	} else {
		msg-result "not found"
	}
	return $r
}

# Note that the return code is not meaningful
proc cc-check-something {name code} {
	uplevel 1 $code
}

# @have-feature name ?default=0?
#
# Returns the value of the feature if defined, or $default if not.
#
proc have-feature {name {default 0}} {
	get-define [feature-define-name $name] $default
}

# @define-feature name ?value=1?
#
# Sets the feature 'define' to the given value.
#
proc define-feature {name {value 1}} {
	define [feature-define-name $name] $value
}

# @feature-checked name
#
# Returns 1 if the feature has been checked, whether true or not
#
proc feature-checked {name} {
	is-defined [feature-define-name $name]
}

# @feature-define-name name ?prefix=HAVE_?
#
# Converts a name to the corresponding define,
# e.g. sys/stat.h becomes HAVE_SYS_STAT_H.
#
# Converts * to P and all non-alphanumumeric to underscore.
#
proc feature-define-name {name {prefix HAVE_}} {
	string toupper $prefix[regsub -all {[^a-zA-Z0-9]} [regsub -all {[*]} $name p] _]
}

# Checks for the existence of the given function by linking
# Additional cctest args (-includes) may be given
proc cctest_function {function args} {
	cctest -link 1 -declare "extern void $function\(void);" -code "$function\();" {*}$args
}

# Checks for the existence of the given type by compiling
# Additional cctest args be given
proc cctest_type {type args} {
	cctest -code "$type _x;" {*}$args
}

# Checks for the existence of the given type/structure member.
# e.g. "struct stat.st_mtime"
# Additional cctest args be given
proc cctest_member {struct_member args} {
	lassign [split $struct_member .] struct member
	cctest -code "static $struct _s; return sizeof(_s.$member);" {*}$args
}

# @cc-check-sizeof ?-args? type ...
#
# Checks the size of the given types (between 2 and 32).
# Defines a variable with the size determined, or "unknown" otherwise.
# e.g. for type 'long long', defines SIZEOF_LONG_LONG.
# Returns the size of the last type.
# The first arg may be a list of additional arguments to cctest.
#
proc cc-check-sizeof {args} {
	lassign [cc-extract-args $args] args extra
	foreach type $args {
		msg-checking "Checking for sizeof $type..."
		set size unknown
		foreach i {2 4 8 16 32} {
			if {[cctest {*}$extra -code "static int _x\[sizeof($type) - $i + 1\];"] == 0} {
				break
			}
			set size $i
		}
		msg-result $size
		set define [feature-define-name $type SIZEOF_]
		define $define $size
	}
	# Return the last result
	get-define $define
}

proc cc-extract-args {list} {
	set extra ""
	if {[string match -* [lindex $list 0]]} {
		set list [lassign $list extra]
		if {[llength $extra] % 2} {
			autosetup-error "Option list is missing a value: $extra"
		}
	}
	list $list $extra
}

# Checks for each feature in $list by using the given script.
# If the first argument of $list starts with a dash,
# it is taken to be a list of arguments to cctet, (e.g. -includes ...)
#
# When the script is evaluated, $each is set to the feature
# being checked, and $extra is set to any additional cctest args.
#
# Returns 1 if all features were found, or 0 otherwise.
proc cc-check-some-feature {list script} {
	lassign [cc-extract-args $list] list extra
	set ret 1
	foreach each $list {
		if {![check-feature $each $script]} {
			set ret 0
		}
	}
	return $ret
}

# @cc-check-includes ?-args? includes ...
#
# Checks that the given include files can be used
# The first arg may be a list of additional arguments to cctest.
proc cc-check-includes {args} {
	cc-check-some-feature $args {
		cctest {*}$extra -includes $each
	}
}

# @cc-check-types ?-args? type ...
#
# Checks that the types exist.
# The first arg may be a list of additional arguments to cctest.
proc cc-check-types {args} {
	cc-check-some-feature $args {
		cctest_type $each {*}$extra
	}
}

# @cc-check-functions ?-args? function ...
#
# Checks that the given functions exist (can be linked)
# The first arg may be a list of additional arguments to cctest.
proc cc-check-functions {args} {
	cc-check-some-feature $args {
		cctest_function $each {*}$extra
	}
}

# @cc-check-members ?-args? type.member ...
#
# Checks that the given type/structure members exist.
# A structure member is of the form "struct stat.st_mtime"
# The first arg may be a list of additional arguments to cctest.
proc cc-check-members {args} {
	cc-check-some-feature $args {
		cctest_member $each {*}$extra
	}
}

# @cc-check-function-in-lib function libs ?otherlibs?
#
# Checks that the given given function can be found on one of the libs.
#
# First checks for no library required, then checks each of the libraries
# in turn.
#
# If the function is found, the feature is defined and lib_$function is defined
# to -l$lib where the function was found, or "" if no library required.
# In addition, -l$lib is added to the LIBS define.
#
# If additional libraries may be needed to linked, they should be specified
# as $extralibs as "-lotherlib1 -lotherlib2".
# These libraries are not automatically added to LIBS.
#
# Returns 1 if found or 0 if not.
# 
proc cc-check-function-in-lib {function libs {otherlibs {}}} {
	msg-checking "Checking for $function..."
	set found 0
	if {[cctest_function $function]} {
		msg-result "none needed"
		define lib_$function ""
		incr found
	} else {
		foreach lib $libs {
			if {[cctest_function $function -libs [list -l$lib {*}$otherlibs]]} {
				msg-result $lib
				define lib_$function -l$lib
				define-append LIBS -l$lib
				incr found
				break
			}
		}
	}
	if {$found} {
		define [feature-define-name $function]
	} else {
		msg-result "not found"
	}
	return $found
}

# @cc-check-tools tool ...
#
# Checks for existence of the given compiler tools, taking
# into account any cross compilation prefix.
#
# For example, when checking for "ar", first AR is checked on the command
# line and then in the environment. If not found, "${host}-ar" or
# simply "ar" is assumed depending upone whether cross compiling.
# The path is searched for this executable, and if found AR is defined
# to the executable name.
#
# It is an error if the executable is not found.
#
proc cc-check-tools {args} {
	foreach tool $args {
		set TOOL [string toupper $tool]
		set exe [get-env $TOOL [get-define cross]$tool]
		if {![find-executable $exe]} {
			user-error "Failed to find $exe"
		}
		define $TOOL $exe
	}
}

# @cc-check-progs prog ...
#
# Checks for existence of the given executables on the path.
#
# For example, when checking for "grep", the path is searched for
# the executable, 'grep', and if found GREP is defined as "grep".
#
# It the executable is not found, the variable is defined as false.
# Returns 1 if all programs were found, or 0 otherwise.
#
proc cc-check-progs {args} {
	set failed 0
	foreach prog $args {
		set PROG [string toupper $prog]
		msg-checking "Checking for $prog..."
		if {![find-executable $prog]} {
			msg-result no
			define $PROG false
			incr failed
		} else {
			msg-result ok
			define $PROG $prog
		}
	}
	expr {!$failed}
}

# @cctest ?settings?
# 
# Low level C compiler checker. Compiles and or links a small C program
# according to the arguments and returns 1 if OK, or 0 if not.
#
# Supported settings are:
#
## -cflags cflags      A list of flags to pass to the compiler
## -includes list      A list of includes, e.g. {stdlib.h stdio.h}
## -declare code       Code to declare before main()
## -link 1             Don't just compile, link too
## -libs liblist       List of libraries to link, e.g. {-ldl -lm}
## -code code          Code to compile in the body of main()
## -source code        Compile a complete program. Ignore -includes, -declare and -code
## -sourcefile file    Shorthand for -source [readfile [get-define srcdir]/$file]
#
# Unless -source or -sourcefile is specified, the C program looks like:
#
## #include <firstinclude>   /* same for remaining includes in the list */
##
## declare-code              /* any code in -declare, verbatim */
##
## int main(void) {
##   code                    /* any code in -code, verbatim */
##   return 0;
## }
#
# Any failures are recorded in 'config.log'
#
proc cctest {args} {
	set src conftest__.c
	set tmp conftest__.o

	array set opts {-cflags {} -includes {} -declare {} -link 0 -libs {} -code {}}
	array set opts $args

	if {[info exists opts(-sourcefile)]} {
		set opts(-source) [readfile [get-define srcdir]/$opts(-sourcefile) "#error can't find $opts(-sourcefile)"]
	}
	if {[info exists opts(-source)]} {
		set lines $opts(-source)
	} else {
		foreach i $opts(-includes) {
			if {$opts(-code) eq "" || [have-feature $i]} {
				lappend source "#include <$i>"
			} elseif {![feature-checked $i]} {
				user-notice "Warning: using #include <$i> which has not been checked -- ignoring"
			}
		}
		lappend source $opts(-declare)
		lappend source "int main(void) {"
		lappend source $opts(-code)
		lappend source "return 0;"
		lappend source "}"

		set lines [join $source \n]
	}

	writefile $src $lines\n
	set ccopts -c
	if {$opts(-link)} {
		set ccopts ""
	}
	lappend ccopts {*}$opts(-cflags)
	switch -glob -- [get-define host] {
		*-*-darwin* {
			# Don't generate .dSYM directories
			lappend ccopts -gstabs
		}
	}
	set cmdline [list {*}[get-define CC] {*}[get-define CFLAGS] {*}$ccopts $src -o $tmp {*}$opts(-libs)]
	set ok 1
	if {[catch {exec {*}$cmdline 2>@1} result errinfo]} {
		configlog "Failed: [join $cmdline]"
		configlog $result
		configlog "============"
		configlog "The failed code was:"
		configlog $lines
		configlog "============"
		set ok 0
	} elseif {$::autosetup(debug)} {
		configlog "Compiled OK: [join $cmdline]"
		configlog "============"
		configlog $lines
		configlog "============"
	}
	file delete $src
	file delete $tmp
	return $ok
}

# If $file doesn't exist, or it's contents are different than $buf,
# the file is written and $script is executed.
# Otherwise a "file is unchanged" message is displayed.
proc write-if-changed {file buf {script {}}} {
	set old [readfile $file ""]
	if {$old eq $buf && [file exists $file]} {
		msg-result "$file is unchanged"
	} else {
		writefile $file $buf\n
		uplevel 1 $script
	}
}

# Examines all defines which match the given patterns
# and writes an include file, $file, which defines each of these.
# - defines which have the value "0" are ignored.
# - defines which have integer values are defined as the integer value.
# - any other value is defined as a string, e.g. "value"
# 
# If the file would be unchanged, it is not written.
proc make-autoconf-h {file {patterns {HAVE_* SIZEOF_*}}} {
	set guard _[string toupper [regsub -all {[^a-zA-Z0-9]} [file tail $file] _]]
	file mkdir [file dirname $file]
	set lines {}
	lappend lines "#ifndef $guard"
	lappend lines "#define $guard"
	foreach pattern $patterns {
		foreach n [lsort [array names ::define $pattern]] {
			if {$::define($n) eq "0"} {
				lappend lines "/* #undef $n */"
			} elseif {[string is integer -strict $::define($n)]} {
				lappend lines "#define $n $::define($n)"
			} else {
				lappend lines "#define $n \"$::define($n)\""
			}
		}
	}
	lappend lines "#endif"
	set buf [join $lines \n]
	write-if-changed $file $buf {
		msg-result "Created $file"
	}
}

# Reads the input file <srcdir>/$template and writes the output file $out.
# If $out is blank/omitted, $template should end with ".in" which
# is removed to create the output file name.
#
# Each pattern of the form @define@ is replaced the the corresponding
# define, if it exists, or left unchanged if not.
# 
proc make-template {template {out {}}} {
	set infile [file join $::autosetup(srcdir) $template]

	if {![file exists $infile]} {
		user-error "Template $template is missing"
	}

	# Define this as late as possible
	define AUTODEPS $::autosetup(deps)

	if {$out eq ""} {
		if {[file ext $template] ne ".in"} {
			autosetup-error "make_template $template has no target file and can't guess"
		}
		set out [file tail [file rootname $template]]
	}

	set mapping {}
	foreach {n v} [array get ::define] {
		lappend mapping @$n@ $v
	}
	writefile $out [string map $mapping [readfile $infile]]\n

	msg-result "Created $out from $template"
}

# build/host tuples and cross-compilation prefix
set build [opt-val build]
define build_alias $build
if {$build eq ""} {
	define build [config_guess]
} else {
	define build [config_sub $build]
}

set host [opt-val host]
if {$host eq ""} {
	set host $build
}
define host_alias $host
if {$host eq ""} {
	define host [get-define build]
	set cross ""
} else {
	define host [config_sub $host]
	set cross $host-
}
define cross [get-env CROSS $cross]

set prefix [opt-val prefix /usr/local]

# These are for compatibility with autoconf
define prefix $prefix
define builddir [pwd]
define srcdir $autosetup(srcdir)
define target [get-define host]
define exec_prefix \${prefix}
define bindir \${exec_prefix}/bin
define sbindir \${exec_prefix}/sbin
define libexecdir \${exec_prefix}/libexec
define datadir \${prefix}/share
define sysconfdir \${prefix}/etc
define sharedstatedir \${prefix}/com
define localstatedir \${prefix}/var
define libdir \${exec_prefix}/lib
define infodir \${prefix}/share/info
define mandir \${prefix}/share/man
define includedir \${prefix}/include

# Initialise some values from the environment or commandline or default settings
foreach i {LDFLAGS LIBS CPPFLAGS LINKFLAGS {CFLAGS "-g -O2"} {CC_FOR_BUILD cc}} {
	lassign $i var default
	define $var [get-env $var $default]
}

define CC [find-an-executable [get-env CC [get-define cross]cc] [get-define cross]gcc]
if {[get-define CC] eq ""} {
	user-error "Could not find a C compiler such as [get-define cross]gcc"
}

define CPP [get-env CPP "[get-define CC] -E"]

cc-check-tools ld

foreach i {EXEEXT SH_CFLAGS SH_LDFLAGS SHOBJ_CFLAGS SHOBJ_LDFLAGS} {
	define $i ""
}

# Windows vs. non-Windows
switch -glob -- [get-define host] {
	*-*-ming* - *-*-cygwin {
		define-feature windows
		define EXEEXT .exe
	}
	default {
		define EXEEXT ""
	}
}

puts "Host System...[get-define host]"
puts "Build System...[get-define build]"
puts "C compiler...[get-define CC] [get-define CFLAGS]"

if {![cc-check-includes stdlib.h]} {
	user-error "Compiler does not work. See config.log"
}
