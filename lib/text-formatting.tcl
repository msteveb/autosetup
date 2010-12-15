# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting

use formatting

proc wordwrap {text length {firstprefix ""} {nextprefix ""}} {
    set len 0
    set space $firstprefix
    foreach word [split $text] {
        set word [string trim $word]
        if {$word == ""} {
            continue
        }
        if {$len && [string length $space$word] + $len >= $length} {
            puts ""
            set len 0
            set space $nextprefix
        }
        incr len [string length $space$word]

        # Use man-page conventions for highlighting 'quoted' and *quoted*
        # single words.
        # Use x^Hx for *bold* and _^Hx for 'underline'.
        #
        # less and more will both understand this.
        # Pipe through 'col -b' to remove them.
        if {[regexp {^'(.*)'([^a-zA-Z0-9_]*)$} $word -> bareword dot]} {
            regsub -all . $bareword "_\b&" word
            append word $dot
        } elseif {[regexp {^[*](.*)[*]([^a-zA-Z0-9_]*)$} $word -> bareword dot]} {
            regsub -all . $bareword "&\b&" word
            append word $dot
        }
        puts -nonewline $space$word
        set space " "
    }
    if {$len} {
        puts ""
    }
}
proc title {text} {
    underline [string trim $text] =
    nl
}
proc p {text} {
    wordwrap $text 80
    nl
}
proc code {text} {
    foreach line [parse_code_block $text] {
        puts "    $line"
    }
    nl
}
proc nl {} {
    puts ""
}
proc underline {text char} {
    regexp "^(\[ \t\]*)(.*)" $text -> indent words
    puts $text
    puts $indent[string repeat $char [string length $words]]
}
proc section {text} {
    underline "[incr ::section]. [string trim $text]" -
    set ::subsection 0
    nl
}
proc subsection {text} {
    underline "$::section.[incr ::subsection]. $text" ~
    nl
}
proc bullet {text} {
    wordwrap $text 76 "  * " "    "
}
proc indent {text} {
    wordwrap $text 76 "    " "    "
}
proc defn {first args} {
    if {$first ne ""} {
        underline "    $first" ~
    }
    foreach p $args {
        if {$p ne ""} {
            indent $p
        }
    }
}
