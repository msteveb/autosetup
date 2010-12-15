# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting
# wiki.tcl.tk format output

use formatting

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
    puts "======"
    foreach line [parse_code_block $text] {
        puts "    $line"
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
