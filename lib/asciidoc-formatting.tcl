# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting

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
    # If the text begins with newline, skip it
    regexp {^\n(.*)} $text -> text

    # And trip spaces off the end
    set text [string trimright $text]

    # Find the indent of the first line
    # so that can be removed from every line
    set indent ""
    regexp "^(\[ \t\]\+)" $text -> indent
    set len [string length $indent]

    foreach line [split $text \n] {
        puts "    [string range $line $len end]"
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
    underline "[incr ::section]. [para $text]" -
    set ::subsection 0
    nl
}
proc subsection {text} {
    underline "$::section.[incr ::subsection]. $text" ~
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
