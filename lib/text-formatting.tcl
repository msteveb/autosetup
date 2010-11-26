# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting

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
        # Use x^Hx hightlighting for 'quoted' single words
        if {[regexp {^'(.*)'([^a-zA-Z0-9_]*)$} $word -> bareword dot]} {
            regsub -all . $bareword "&\010&" word
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
    # Find the indent of the first non-blank line
    set indent ""
    regexp "^\n(\[ \t\]\+)" $text dummy indent
    set len [string length $indent]
    # Trim initial newline and trailing space
    set text [string trimleft $text \n]
    foreach line [split $text \n] {
        puts "    [string range $line $len end]"
    }
}
proc nl {} {
    puts ""
}
proc underline {text char} {
    regexp {^([ \t]*)(.*)} $text -> indent words
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
