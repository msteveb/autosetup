# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting
# wiki.tcl.tk format output

proc joinlines {text} {
    set lines {}
    foreach l [split [string trim $text] \n] {
        lappend lines [string trim $l]
    }
    join $lines
}
proc p {text} {
    puts [joinlines $text]
    puts ""
}
proc title {text} {
    puts "*** [joinlines $text] ***"
    puts ""
}
proc code {text} {
    # If the text begins with newline, skip it
    regexp {^\n(.*)} $text -> text

    # And trip spaces off the end
    set text [string trimright $text]

    # Find the indent of the first line
    # so that can be removed from every line
    set indent ""
    regexp "^(\[ \t\]\+)" $text -> indent
    set len [string length $indent]

    puts "======"
    foreach line [split $text \n] {
        puts "  [string range $line $len end]"
    }
    puts "======"
}
proc nl {} {
}
proc section {text} {
    puts "'''[incr ::section]. $text'''"
    puts ""
    set ::subsection 0
}
proc subsection {text} {
    puts "''$::section.[incr ::subsection]. $text''"
    puts ""
}
proc bullet {text} {
    puts "   * [joinlines $text]"
}
proc indent {text} {
    puts "    :    [joinlines $text]"
}
proc defn {first args} {
    if {$first ne ""} {
        indent '''$first'''
    }

    foreach p $args {
        p $p
    }
}
