# Copyright (c) 2010 WorkWare Systems http://workware.net.au/
# All rights reserved

# Module which provides usage, help and the manual

proc autosetup_help {what} {
    puts "Usage: [file tail $::autosetup(exe)] \[options\] \[settings\]"
    puts \
{
   This is autosetup, a faster, better alternative to autoconf.
   Use the --manual option for the full autosetup manual.
}
    if {$what eq "local"} {
        if {[file exists $::autosetup(autodef)]} {
            # This relies on auto.def having a call to 'options'
            # which will display options and quit
            source $::autosetup(autodef)
        } else {
            options-show
        }
    } else {
        incr ::autosetup(showhelp)
        if {[catch {use $what}]} {
            user-error "Unknown module: $what"
        } else {
            options-show
        }
    }
    exit 0
}

# Outputs the autosetup manual in one of several formats
proc autosetup_manual {{type text}} {

    switch -glob -- $type {
        wiki {use wiki-formatting}
        ascii* {use asciidoc-formatting}
        default {use text-formatting}
    }

    title "[autosetup_version] -- User Manual"

    section {Introduction}
    p {
        'autosetup' is a tool, similar to 'autoconf', to configure a build system for the
        appropriate environment, according to the system capabilities and the user configuration.
    }
    p {
        autosetup is designed to be light-weight, fast, simple and flexible.
    }
    p {
        Notable features include:
    }
    bullet {Easily check for headers, functions, types for C/C++}
    bullet {Easily support user configuration options}
    bullet {Can generate files based on templates, such as Makefile.in => Makefile}
    bullet {Can generate header files based on checked features}
    bullet {Excellent support for cross compilation}
    bullet {Replacement for autoconf in many situations}
    bullet {Runs with either Tcl 8.5+, Jim Tcl or just a C compiler (using the included Jim Tcl source code!)}
    bullet {autosetup is intended to be distributed with projects - no version issues}
    nl
    p {
        autosetup is particularly targeted towards building C/C++ applications on Unix
        systems, however it can be extended for other environments as needed.
    }
    p {
        autosetup is *not*:
    }
    bullet {A build system}
    bullet {A replacement for automake}
    bullet {Intended to replace all possible uses of autoconf}
    nl

    section {Usage}
    p {
        autosetup accepts both standard options as well as local options
        defined in the 'auto.def' file, and options for modules.
        Use 'autosetup --help' to show all available options.
    }
    code {
        autosetup ?options? ?settings?
    }
    p {
        Some important core options are:
    }
    code {
        -C dir           change to the given directory before running autosetup
        --help           display help and options
        --version        display the version of autosetup
        --manual?=text?  display the autosetup manual. Alternative formats are 'wiki' and 'asciidoc'
        --install        install autosetup to the current directory
        --init           create an initial 'configure' script if none exists
    }
    p {
        Settings are of the form 'name=value' and must be after any options.
        These settings allow the default values to be overridden for variables such
        as 'CC' and 'CFLAGS'.
    }
    p {
        Optional modules may support additional options. For example, the cc module
        supports the following additional options.
    }
    code {
        --host=host-alias     a complete or partial cpu-vendor-opsys for the system where the
                              application will run (defaults to the same value as --build)
        --build=build-alias   a complete or partial cpu-vendor-opsys for the system where the
                              application will be built (defaults to the result of running
                              config.guess)
        --prefix=dir          the target directory for the build (defaults to /usr/local)
    }

    p {
        Typically, autosetup is invoked via a simpler wrapper script, 'configure'.
        This provides for compatibility with autoconf.
        For example:
    }
    code {
        ./configure --host=arm-linux --utf8 --prefix=/usr CFLAGS="-g -Os"
    }

    section {Features}

    subsection {Configuration Descriptions are Tcl}

    p {
        Configuration requirements are given in an 'auto.def' file and are
        written in 'Tcl', a language slightly less obscure than 'm4'!
        As a full language, there are no additional dependencies on the
        host system such as 'awk', 'sed' and 'bash'.
    }
    p {
        Tcl is widely available on modern development platforms. Configuration descriptions
        are designed to look more like declarations than code. It is easy to write
        autosetup configuration descriptions with no knowledge of Tcl.
    }

    subsection {Simple Configuration Descriptions}
    p {
        A typical, simple auto.def file is:
    }
    code {
        use cc

        options {
            shared => "build a shared library"
            lineedit=1 => "disable line editing"
            utf8 => "enabled UTF-8 support"
            with-regexp regexp => "use regexp"
        }

        cc-check-types "long long"
        cc-check-includes sys/un.h dlfcn.h
        cc-check-functions ualarm sysinfo lstat fork vfork
        cc-check-function-in-lib sqlite3_open sqlite3

        if {[opt-bool utf8] && [have-feature fork]} {
            msg-result "Enabling UTF-8"
            define JIM_UTF8
        }
        make-autoconf-h config.h
        make-template Makefile.in
    }

    subsection {Fast}
    p {
        All the processing occurs in a single process, aside from invocations of the C compiler.
        Here are the results of a typical configure for a small project. 'autoconf' is particularly
        slow on 'cygwin'.
    }
    code {
                      autoconf     autosetup
                      ---------    ---------
        Linux            4.1s         1.3s
        Mac OS X         6.4s         2.8s
        cygwin          91.5s         9.9s
    }

    subsection {Deploys directly within a project}
    p {
        autosetup is deployed as a single subdirectory, autosetup,
        at the top level of a project, containing a handful of
        files. This approach (inspired by waf - http://code.google.com/p/waf/)
        means that there are no dependency issues with different versions of
        autosetup since an appropriate version is part of the project.
    }
    p {
        autosetup is written in Tcl, but can run under any of the following
        Tcl interpreters:
    }
    bullet {Tcl 8.5 or later}
    bullet {Jim Tcl - a small footprint, portable Tcl interpreter}
    nl
    p {
        The source code for Jim Tcl is included directly within
        autosetup and is automatically built if no other Tcl
        interpreter is available.
    }
    code {
        $ ./configure --help
        No installed jimsh or tclsh, building local bootstrap jimsh0
        Usage: configure [options]

           This is autosetup, a faster, better alternative to autoconf.
           Use the --manual option for the full autosetup manual, including
           standard autosetup options.

        Local options:
          --shared            Create a shared library
          --disable-utf8      Disable utf8 support
    }

    subsection {No separate generate/run step}
    p {
        autosetup parses 'auto.def' and updates the configuration in a single step.
        This simplifies and speeds development. It also means that both developers
        and users (those building the project from source) follow the same configure/build
        procedure.
    }

    section {Writing auto.def files}
    p {
        'auto.def' files are generally simple to write, but have the full
        power of Tcl if required for implementing complex checks or
        option processing. The 'auto.def' file is structured as follows:
    }
    bullet {'use' optional modules}
    bullet {'options' declaration}
    bullet {environment checks and option processing}
    bullet {template, header file and other output generation}
    nl

    subsection {Optional modules}
    p {
        autosetup includes the common, optional modules 'cc' and 'cc-shared'.
        If these modules are required, the *must* be declared *before* 'options' so that
        any module-specific options can be recognised.
    }
    code {
        # This project checks for C/C++ features
        use cc
        # And supports shared libraries/shared objects
        use cc-shared

        options { ... }
    }

    subsection {Declaring User Options}
    p {
        Allowed options are defined using the 'options' declaration in the 'auto.def' file.
    }
    p {
        *Note*: Every auto.def *must* have an 'options' declaration immediately after any 'use'
        declarations, even if it is empty. This ensures that 'configure --help' behaves correctly.
    }
    p {
        Options are declared as follows.
    }
    code {
        options {
            boolopt            => "a boolean option which defaults to disabled"
            boolopt2=1         => "a boolean option which defaults to enabled"
            stringopt:         => "an option which takes an argument, e.g. --stringopt=value"
            stringopt2:=value  => "an option where the argument is optional and defaults to 'value'"
            optalias booltopt3 => "a boolean with a hidden alias. --optalias is not shown in --help"
            boolopt4 => {
                Multiline description for this option
                which is carefully formatted.
            }
        }
    }
    p {
        The '=>' syntax is used to indicate the help description for the option.
        If an option is not followed by '=>', the option is not displayed in '--help'
        but is still available.
    }
    p {
        If the first character of the help description is a newline (as for 'boolopt4'),
        the description will not be reformatted.
    }
    p {
        String options can be specified multiple times, and all given values are available.
        If there is no default value, the value must be specified.
    }
    p {
        Within 'auto.def', options are checked with the commands 'opt-bool' and 'opt-val'.
    }

    subsection {Setting Options}
    p {
        Boolean options can be enabled or disabled with one of the following forms
        (some of which are for autoconf compatibility):
    }
    p {
        To *enable* an option:
    }
    code {
        --boolopt
        --enable-boolopt
        --boolopt=1
        --boolopt=yes
    }
    p {
        To *disable* an option:
    }
    code {
        --disable-boolopt
        --boolopt=0
        --boolopt=no
    }
    p {
        String options must have a value specified, unless the option has a default value.
    }
    code {
        --stropt          - OK if a default value is given for stropt
        --stropt=value    - Adds the given value for the option
    }

    subsection {Configuration Variables}
    p {
        At it's heart, autosetup is about examining user options, performing checks and
        setting configuration variables representing the options and environment.
        These variables are set either directly with the 'define' or 'define-feature' commands,
        or indirectly via one of the test commands such as 'cc-check-includes'.
    }
    p {
        All configuration variables are available for template substitution ('make-template'),
        header file generation ('make-autoconf-h') or can be tested and set within 'auto.def'.
        Certain naming conventions are used to provide expected behaviour.
    }
    p {
        All commands which check for the existence of a feature, use HAVE_xxx as the name of the
        corresponding variable (this is autoconf compatible). See 'feature-define-name' for
        the rules used to convert a feature name to a variable name.
    }
    code {
        cc-check-includes time.h sys/types.h      => HAVE_TIME_H HAVE_SYS_TYPES_H
        cc-check-functions strlcat                => HAVE_STRLCAT
        cc-check-types "long long" "struct stat"  => HAVE_LONG_LONG HAVE_STRUCT_STAT
    }
    p {
        These two are equivalent:
    }
    code {
        have-feature sys/types.h
        get-define HAVE_SYS_TYPE_H
    }
    p {
        'cc-check-sizeof' uses the SIZEOF_ prefix rather than the HAVE_ prefix.
    }
    p {
        Variables used to store command names are simply the uppercase of the base command.
    }
    code {
        CC              - The C compiler
        LD              - The linker
        AR              - ar
        RANLIB          - ranlib
    }

    subsection {configure}
    p {
        In order to provide compatibility with autoconf, and to simplify out-of-tree
        builds, autosetup can be run via a simple 'configure' script. The following
        script is created by 'autosetup --init'.
    }
    code {
        #!/bin/sh
        dir="$(dirname "$0")/autosetup"
        WRAPPER="$0" exec $("$dir/find-tclsh" || echo false) "$dir/autosetup" "$@"
    }
    p {
        This script invokes autosetup in the autosetup/ subdirectory after setting the 'WRAPPER'
        environment variable.
    }
    p {
        'autosetup --init' will create this script if it doesn't exist.
    }

    subsection {Checking Features}
    p {
        Apart from checking user options, the primary purpose of autosetup and 'auto.def'
        is to check for the availability of features in the environment. The 'cc' module
        provides commands to check various settings by compiling small test programs with the
        specified C compiler. The following is a typical example:
    }
    code {
        use cc
        options {}
        cc-check-types "long long"
        cc-check-includes sys/un.h
        cc-check-functions regcomp waitpid sigaction
        cc-check-tools ar ranlib strip
    }
    p {
        See the command reference for details of these built-in checks.
    }

    subsection {Selecting the Language}
    p {
        The low level 'cctest' commands provides the '-lang' option to select the
        language to use for tests. This can be used in conjunction with 'cc-with' to
        set the language for a series of tests.
    }
    code {
        cc-with {-lang c++} {
            # All tests now use the C++ compiler -- $(CXX) and $(CXXFLAGS)
            cc-check-types bool
        }
        # Or just set it for the rest of the file
        cc-with {-lang c++}
        ...
    }

    subsection {Controlling the build}
    p {
        Once the user options have been processed and the environment checked
        for supported features, it is necessary to use this information to
        control the build. The 'cc' module provides two mechanisms for this:
    }
    bullet {'make-template' creates a file from a template by applying substitutions based on
    the configuration variables. For example, replacing '@CC@' with 'arm-linux-gcc'.}
    bullet {'make-autoconf-h' creates a C/C++ header file based on the configuration variables}
    nl
    p {
        It is easy to create other file formats based on configuration variables. For example, to
        produce configuration files in the Linux 'kconfig' format. It is also possible to output configuration
        variables in Makefile format.
    }
    p {
        autosetup has far more control over generating files to control the build than autoconf
        since the configuration variables are directly accessible in 'Tcl' from 'auto.def'.
        See 'all-defines' and 'examples/testbed/auto.def'.
    }

    subsection {A "standard" Makefile.in}
    p {
        If autosetup is being used to control a make-based build system, the use of a
        a 'Makefile.in' with a standard structure will provide behaviour similar to that
        provided by autoconf/automake systems. autosetup provides a typical 'Makefile.in'
        in 'examples/typical/Makefile.in'. This example provides the following:
    }
    bullet {Use CC, AR, RANLIB as determined by cross compiler settings or user overrides}
    bullet {Install to --prefix, overridable with DESTDIR}
    bullet {Use VPATH to support out-of-tree builds}
    bullet {Dummy automake targets to allow for use as a subproject with automake}
    bullet {Automatically reconfigure if auto.def changes}
    nl

    section {Command Reference}
    p {
        autosetup provides a number of built-in commands which
        are documented below. These may be used from 'auto.def' to test
        for features, define variables create files from templates and
        other similar actions.
    }
    p {
        This commands are all implemented as Tcl procedures. Custom commands
        may be added simply by defining additional Tcl procedures in the 'auto.def' file,
        and custom modules may be added by creating files with a '.tcl' extension
        in the autosetup directory.
    }

    automf_command_reference

    section {Examples}
    p {
        autosetup includes a number of examples, including:
    }
    bullet {'examples/typical' - A simple, but full featured example}
    bullet {'examples/minimal' - A minimal example}
    bullet {'examples/jimtcl' - The Jim Tcl project uses autosetup}
    nl
    p {
        These examples can be found along with the autosetup source at
        https://github.com/msteveb/autosetup
    }

    section {Tips on moving from autoconf}
    p {
        autosetup attempts to be reasonably compatible with an autoconf-generated
        'configure' script. Some differences are noted below.
    }
    subsection {No --target, no need for --build}
    p {
        While autosetup has good cross compile support with '--host', it has no explicit support
        for '--target' (which is almost never needed).
    }
    p {
        Additionally, --build is rarely needed since the build system can be guessed
        with 'config.guess'.
    }
    subsection {Single variable namespace}
    p {
        All variables defined with 'define' and 'define-feature' use a single namespace.
        This essentially means that AC_SUBST and AC_DEFINE are equivalent, which simplifies
        configuration in practice.
    }
    subsection {No autoheader}
    p {
        autosetup has no need for 'autoheader' since a configuration header
        file can simply be generated directly (see 'make-autoconf-h') without a template.
    }
    subsection {No subdirectory support}
    p {
        autoconf supports configuring subdirectories with AC_CONFIG_SUBDIRS. autosetup has
        no explicit support for this feature.
    }
    subsection {No automake}
    p {
        autosetup is not designed to be used with automake. autosetup is flexible enough
        to be used with plain 'make', or other builds systems.
    }
    subsection {No AC_TRY_RUN}
    p {
        autosetup has no equivalent of AC_TRY_RUN which attempts to run a test program.
        This feature is often used unnecessarily, and is useless when cross compiling, which
        is a core feature of autosetup.
    }
    subsection {Modern Platform Assumption}
    p {
        autoconf includes support for many old and obsolete platforms. Most of these
        are no longer relevant. autosetup assumes that the build environment is somewhat POSIX compliant.
        This includes both cygwin and mingw on Windows.
    }
    p {Thus, there is no need to check for standard headers such as stdlib.h, string.h, etc.}

    subsection {No AC_PROG_xxxx}
    p {Use the generic 'cc-check-progs'}
    code {
        if {![cc-check-progs grep]} {
            user-error "You don't have grep, but we need it"
        }
        foreach prog {gawk mawk nawk awk} {
            if {[cc-check-progs $prog]} {
                define AWK $prog
                break
            }
        }
        # If not found, AWK is defined as false
    }
    subsection {No AC_FUNC_xxx}
    p {Use the generic 'cc-check-functions' instead}
    subsection {No special commands to use replacement functions}
    p {Instead consider something like the following.}
    code {
        # auto.def: Check all functions
        cc-check-functions strtod backtrace

        /* replacements.c */
        #include "config.h"
        #ifndef HAVE_STRTOD
        double strtod(...) { /* implementation */ }
        #endif
    }
    p {Alternatively, implement each missing function in it's own file.}
    code {
        define EXTRA_OBJS ""
        foreach f {strtod backtrace} {
            if {![cc-check-functions $f]} {
                define-append EXTRA_OBJS $f.o
            }
        }
    }
    subsection {Default checks do not use any include files.}
    p {
        autoconf normally adds certain include files to every test build, such as stdio.h.
        This can cause problems where declarations in these standard headers conflict with
        the code being tested. For this reason, autosetup compile tests uses no standard headers.
        If headers are required, they should be added explicitly.
    }
    subsection {Checking for includes}
    p {
        When adding includes to a test, 'cctest' will automatically omit any include files
        which have been checked and do not exist. If any includes have been specified
        but not checked, a warning is given.
    }

    section {Cross Compiling}
    p {
        In general, cross compilation works the same way as autoconf.
        Generally this simply means specifying --host=<target-alias>.
        For example, if you have arm-linux-gcc and related tools, run:
    }
    code {
        ./configure --host=arm-linux 
    }
    p {
        If additional compiler options are needed, such as -mbig-endian,
        these can be specified with 'CFLAGS'. In this case, the default 'CFLAGS'
        of "-g -O2" won't be used so the desired debugging and optimisation
        flags should also be added.
    }
    code {
        ./configure --host=arm-linux CFLAGS="-mbig-endian -msoft-float -static-libgcc -g -Os"
    }
    p {
        If the compiler and related tools have a non-standard prefix, it may be necessary to set
        CROSS in addition to --host.
    }
    code {
        ./configure --host=arm-linux CROSS=my-
    }
    p {
        In this case, C the compiler should be named my-cc or my-gcc, and similarly for the other
        tools. This is usually simpler than specifying CC, AR, RANLIB, STRIP, etc.
    }

    section {Installing}
    p {
        Like autoconf, autosetup uses a combination of '--prefix' and 'DESTDIR' to determine where the
        project is installed.
    }
    p {
        The '--prefix' option is used during with './configure' to specify the top level installation
        directory. It defaults to '/usr/local'. Use '--prefix=' to install at the top level (e.g. '/bin').
        The application may use this value (via '@prefix@' or one of the related values such as '@bindir@')
        to find files at runtime.
    }
    p {
        The 'DESTDIR' Makefile variable may be used at installation time to specify an different
        install root directory.
        This is especially useful to stage the installed files in a temporary location before they
        are installed to their final location (e.g. when building a filesystem for an embedded target).
        It defaults to the empty string (i.e. files are installed to '--prefix').
    }
    code {
        ./configure --prefix=/usr
        make DESTDIR=/tmp/staging install
    }
    p {
        autosetup has no special support for installing other than providing '--prefix'. The use of
        'DESTDIR' is by convention. In order to provide expected behaviour, Makefile.in should
        contain something like:
    }
    code {
        prefix = @prefix@
        ...
        install: all
            @echo Installing from @srcdir@ and `pwd` to $(DESTDIR)$(prefix)
    }

    section {Automatic remaking}
    p {
        It is convenient for configure to be rerun automatically if any of the input files
        change (for example autosetup or any of the template files). This can be achieved
        by adding the following to Makefile.in.
    }
    code {
        ifeq ($(findstring clean,$(MAKECMDGOALS)),)
        Makefile: @AUTODEPS@ @srcdir@/Makefile.in
                @@AUTOREMAKE@
        endif
    }
    p {
        It may also be convenient to add a target to force reconfiguring with the same options.
    }
    code {
        reconfig:
                @AUTOREMAKE@
    }

    section {Shipping autosetup}
    p {
        autosetup is designed to be deployed directly as part of a project.
        It is installed as a single subdirectory, autosetup, at the
        top level of a project.
    }
    p {
        In addition to autosetup, the following files are required for
        an autosetup-enabled project.
    }
    bullet {auto.def}
    bullet {configure (generated by autosetup --init)}
    bullet {Makefile.in (and any other template specified in auto.def)}
    nl

    section {Extending autosetup}
    p {
        Local modules can be added directly to the autosetup directory and loaded
        with the 'use' command.
    }
    section {Future Features/Changes}
    p {
        Some features are not yet implemented, but are candidates for including
        in an existing module, or adding to a new module. Others may require
        changes to the core 'autosetup'.
    }
    bullet {Explicit C++ support}
    bullet {pkg-config support (although pkg-config has poor support for cross compiling)}
    bullet {More fully-featured shared library support}
    bullet {Support for additional languages}
    bullet {libtool support (if we must!)}
    bullet {
        Subdirectory support. Need to resolve how options are parsed, and
        how variables interact between subdirectories.
    }

    section {Motivation}
    p {
        autoconf does the job and supports many platforms, but it suffers
        from at least the following problems:
    }
    bullet {Requires configuration descriptions in a combination of m4 and shell scripts}
    bullet {Creates 10,000 line shell scripts which are slow to run and impossible to debug}
    bullet {Requires a multi-stage process of aclocal => autoheader => autoconf =>
            configure => Makefile + config.h}
    nl
    p {
        autosetup attempts to address these issues as follows by directly
        parsing a simple 'auto.def' file, written in Tcl, and directly
        generating output files such as config.h and Makefile.
    }
    p {
        autosetup runs under either Tcl 8.5, which is available on almost any
        modern system, or Jim Tcl. Jim Tcl is very easy to build on almost any
        system in the case where Tcl is not available.
    }
    section {References}
    bullet {http://freshmeat.net/articles/stop-the-autoconf-insanity-why-we-need-a-new-build-system}
    bullet {http://www.varnish-cache.org/docs/2.1/phk/autocrap.html}
    bullet {http://wiki.tcl.tk/27197}
    bullet {http://jim.berlios.de/}
    bullet {http://www.gnu.org/software/hello/manual/autoconf/index.html}
    bullet {http://www.flameeyes.eu/autotools-mythbuster/index.html}
    nl

    subsection {Comments on autoconf}
    bullet {http://news.ycombinator.com/item?id=1499738}
    bullet {http://developers.slashdot.org/article.pl?sid=04/05/21/0154219}
    bullet {http://www.airs.com/blog/archives/95}
    nl

    subsection {Alternative autoconf Alternatives}
    bullet {http://pmk.sourceforge.net/faq.php - PMK}
    bullet {https://e-reports-ext.llnl.gov/pdf/315457.pdf - autokonf}
    nl

    section {Copyright, Author and Licence}
    p {
        autosetup is Copyright (c) 2010 WorkWare Systems http://workware.net.au/
    }
    p {
        autosetup was written by Steve Bennett <steveb@workware.net.au>
    }
    p {
        autosetup is released under the "2-clause FreeBSD Licence" as follows.
    }
    code {
        autosetup - An environment "autoconfigurator"

        Copyright 2010 Steve Bennett <steveb@workware.net.au>

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions
        are met:

        1) Redistributions of source code must retain the above copyright
           notice, this list of conditions and the following disclaimer.
        2) Redistributions in binary form must reproduce the above
           copyright notice, this list of conditions and the following
           disclaimer in the documentation and/or other materials
           provided with the distribution.

        THIS SOFTWARE IS PROVIDED BY THE WORKWARE SYSTEMS ``AS IS'' AND ANY
        EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
        THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
        PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL WORKWARE
        SYSTEMS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
        INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
        OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
        HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
        STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
        ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
        ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

        The views and conclusions contained in the software and documentation
        are those of the authors and should not be interpreted as representing
        official policies, either expressed or implied, of WorkWare Systems.
    }

    exit 0
}

# Helps output formatted text from inline documentation
proc accumulate_reference_line {statename type str} {
    upvar $statename state

    dputs "=> ($state(type)) $type: [string trim $str]"
    switch -glob $state(type),$type {
        code,code - desc,desc - defn,desc - none,code - none,defn {
            dputs "   => accum"
            lappend state(buf) $str
        }
        code,none - code,defn - code,desc {
            dputs "   => code"
            # Need to add an initial newline so that indenting is preserved
            code \n[join $state(buf) \n]
            nl
            if {$type eq "desc"} {
                set state(buf) [list "" $str]
            } else {
                set state(buf) [list]
            }
        }
        none,desc {
            set type none
        }
        desc,* - defn,* {
            dputs "   => defn"
            defn [lindex $state(buf) 0] [join [lrange $state(buf) 1 end] \n]
            nl
            set state(buf) [list]
            if {$type eq "code"} {
                lappend state(buf) $str
            }
        }
    }
    if {$type eq "none"} {
        dputs "   => reset"
        set state(buf) [list]
    }
    set state(type) $type
}

# Generate a command reference from inline documentation
proc automf_command_reference {} {
    lappend files $::autosetup(prog)
    if {!$::autosetup(installed)} {
        lappend files {*}[lsort [glob -nocomplain $::autosetup(libdir)/*.tcl]]
    }
    subsection {Core Commands}
    foreach file $files {
        set state(buf) [list]
        set state(type) none
        foreach line [split [readfile $file] \n] {
            if {[regexp {^# @synopsis:$} $line -> str]} {
                subsection "Module: [file rootname [file tail $file]]"
                set state(type) desc
                continue
            }
            if {[regexp {^##($| .*)} $line -> str]} {
                accumulate_reference_line state code $str
                continue
            }
            if {[regexp {^# @(.*)} $line -> str]} {
                accumulate_reference_line state defn $str
                continue
            }
            if {[regexp {^#(.*)} $line -> str]} {
                accumulate_reference_line state desc [string trim $str]
                continue
            }
            accumulate_reference_line state none ""
        }
    }
}
