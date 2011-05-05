# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting
# asciidoc format

use formatting

proc para {text} {
    regsub -all "\[ \t\n\]+" [string trim $text] " "
}
proc title {text} {
    underline [para $text] =
    nl
}
proc p {text} {
    puts [para $text]
    nl
}
proc code {text} {
    foreach line [parse_code_block $text] {
        puts "    $line"
    }
    nl
}
proc codelines {lines} {
    foreach line $lines {
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
    underline "[para $text]" -
    nl
}
proc subsection {text} {
    underline "$text" ~
    nl
}
proc bullet {text} {
    puts "* [para $text]"
}
proc indent {text} {
    puts " :: "
    puts [para $text]
}
proc defn {first args} {
    set sep ""
    if {$first ne ""} {
        puts "${first}::"
    } else {
        puts " :: "
    }
    set defn [string trim [join $args \n]]
    regsub -all "\n\n" $defn "\n ::\n" defn
    puts $defn
}
