# Copyright (c) 2010 WorkWare Systems http://workware.net.au/
# All rights reserved

# Module which provides usage, help and the command reference

proc autosetup_help {what} {
    use_pager

    puts "Usage: [file tail $::autosetup(exe)] \[options\] \[settings\]\n"
    puts "This is [autosetup_version], a build environment \"autoconfigurator\""
    puts "See the documentation online at https://msteveb.github.io/autosetup/\n"

    if {$what in {all local}} {
        # Need to load auto.def now
        if {[file exists $::autosetup(autodef)]} {
            # Load auto.def as module "auto.def"
            autosetup_load_module auto.def source $::autosetup(autodef)
        }
        if {$what eq "all"} {
            set what *
        } else {
            set what auto.def
        }
    } else {
        use $what
        puts "Options for module $what:"
    }
    options-show $what
    exit 0
}

proc autosetup_show_license {} {
    global modsource autosetup
    use_pager

    if {[info exists modsource(LICENSE)]} {
        puts $modsource(LICENSE)
        return
    }
    foreach dir [list $autosetup(libdir) $autosetup(srcdir)] {
        set path [file join $dir LICENSE]
        if {[file exists $path]} {
            puts [readfile $path]
            return
        }
    }
    puts "LICENSE not found"
}

# If not already paged and stdout is a tty, pipe the output through the pager
# This is done by reinvoking autosetup with --nopager added
proc use_pager {} {
    if {![opt-bool nopager] && [getenv PAGER ""] ne "" && [isatty? stdin] && [isatty? stdout]} {
        if {[catch {
            exec [info nameofexecutable] $::argv0 --nopager {*}$::argv |& {*}[getenv PAGER] >@stdout <@stdin 2>@stderr
        } msg opts] == 1} {
            if {[dict get $opts -errorcode] eq "NONE"} {
                # an internal/exec error
                puts stderr $msg
                exit 1
            }
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
        See https://msteveb.github.io/autosetup/ for the online documentation for 'autosetup'.
        This documentation can also be accessed locally with `autosetup --ref`.
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
            section {
                section $lines
            }
            subsection {
                subsection $lines
            }
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

    # We want to process all non-module files before module files
    # and then modules in alphabetical order.
    # So examine all files and extract docs into doc($modulename) and doc(_core_)
    #
    # Each entry is a list of {type data} where $type is one of: section, subsection, code, list, p
    # and $data is a string for section, subsection or a list of text lines for other types.

    # XXX: Should commands be in alphabetical order too? Currently they are in file order.

    set doc(_core_) {}
    lappend doc(_core_) [list section "Core Commands"]

    foreach file $files {
        set modulename [file rootname [file tail $file]]
        set current _core_
        set f [open $file]
        while {![eof $f]} {
            set line [gets $f]

            if {[regexp {^#.*@section (.*)$} $line -> section]} {
                lappend doc($current) [list section $section]
				continue
			}

            # Find embedded module names
            if {[regexp {^#.*@module ([^ ]*)} $line -> modulename]} {
                continue
            }

            # Find lines starting with "# @*" and continuing through the remaining comment lines
            if {![regexp {^# @(.*)} $line -> cmd]} {
                continue
            }

            # Synopsis or command?
            if {$cmd eq "synopsis:"} {
                set current $modulename
                lappend doc($current) [list section "Module: $modulename"]
			} else {
                lappend doc($current) [list subsection $cmd]
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
                    lappend doc($current) [list $type $lines]
                    set lines {}
                    set type $t
                }
                if {$cmd ne ""} {
                    lappend lines $cmd
                }
            }

            lappend doc($current) [list $type $lines]
        }
        close $f
    }

    # Now format and output the results

    # _core_ will sort first
    foreach module [lsort [array names doc]] {
        foreach item $doc($module) {
            autosetup_output_block {*}$item
        }
    }
}
