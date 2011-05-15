# Copyright (c) 2010 WorkWare Systems http://workware.net.au/
# All rights reserved

# Module which provides usage, help and the command reference

proc autosetup_help {what} {
    use_pager

    puts "Usage: [file tail $::autosetup(exe)] \[options\] \[settings\]\n"
    puts "This is [autosetup_version], a build environment \"autoconfigurator\""
    puts "See the documentation online at http://msteveb.github.com/autosetup/\n"

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

# If not already paged and stdout is a tty, pipe the output through the pager
# This is done by reinvoking autosetup with --nopager added
proc use_pager {} {
    if {![opt-bool nopager] && [env PAGER ""] ne "" && ![string match "not a tty" [exec tty]]} {
        catch {
            exec [info nameofexecutable] $::argv0 --nopager {*}$::argv | [env PAGER] >@stdout <@stdin 2>/dev/null
        }
        exit 0
    }
}

# Outputs the autosetup references in one of several formats
proc autosetup_reference {{type text}} {

    use_pager

    switch -glob -- $type {
        wiki {use wiki-formatting}
        ascii* {use asciidoc-formatting}
        md - markdown {use markdown-formatting}
        default {use text-formatting}
    }

    title "[autosetup_version] -- Command Reference"

    section {Introduction}

    p {
        See http://msteveb.github.com/autosetup/ for the online documentation for 'autosetup'
    }

    p {
        'autosetup' provides a number of built-in commands which
        are documented below. These may be used from 'auto.def' to test
        for features, define variables, create files from templates and
        other similar actions.
    }

    automf_command_reference

    exit 0
}

proc autosetup_output_block {type lines} {
    if {[llength $lines]} {
        switch $type {
            code {
                codelines $lines
            }
            p {
                p [join $lines]
            }
            list {
                foreach line $lines {
                    bullet $line
                }
                nl
            }
        }
    }
}

# Generate a command reference from inline documentation
proc automf_command_reference {} {
    lappend files $::autosetup(prog)
    lappend files {*}[lsort [glob -nocomplain $::autosetup(libdir)/*.tcl]]

    section "Core Commands"
    set type p
    set lines {}
    set cmd {}

    foreach file $files {
        set f [open $file]
        while {![eof $f]} {
            set line [gets $f]

            # Find lines starting with "# @*" and continuing through the remaining comment lines
            if {![regexp {^# @(.*)} $line -> cmd]} {
                continue
            }

            # Synopsis or command?
            if {$cmd eq "synopsis:"} {
                section "Module: [file rootname [file tail $file]]"
            } else {
                subsection $cmd
            }

            set lines {}
            set type p

            # Now the description
            while {![eof $f]} {
                set line [gets $f]

                if {![regexp {^#(#)? ?(.*)} $line -> hash cmd]} {
                    break
                }
                if {$hash eq "#"} {
                    set t code
                } elseif {[regexp {^- (.*)} $cmd -> cmd]} {
                    set t list
                } else {
                    set t p
                }

                #puts "hash=$hash, oldhash=$oldhash, lines=[llength $lines], cmd=$cmd"

                if {$t ne $type || $cmd eq ""} {
                    # Finish the current block
                    autosetup_output_block $type $lines
                    set lines {}
                    set type $t
                }
                if {$cmd ne ""} {
                    lappend lines $cmd
                }
            }

            autosetup_output_block $type $lines
        }
        close $f
    }
}
