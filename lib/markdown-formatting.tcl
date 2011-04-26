# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting
# markdown format (kramdown syntax)

use formatting

proc para {text} {
    regsub -all "\[ \t\n\]+" [string trim $text] " " text
    regsub -all {([^a-zA-Z])'([^']*)'} $text {\1**`\2`**} text
    regsub -all {^'([^']*)'} $text {**`\1`**} text
    regsub -all {(http[^ \t\n]*)} $text {[\1](\1)} text
    return $text
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
    puts "~~~~~~~~~~~~"
    foreach line [parse_code_block $text] {
        puts $line
    }
    puts "~~~~~~~~~~~~"
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
    puts "### $::section.[incr ::subsection]. $text"
    nl
}
proc bullet {text} {
    puts "* [para $text]"
}
proc defn {first args} {
    puts "^"
    set defn [string trim [join $args \n]]
    if {$first ne ""} {
        puts "**${first}**"
        puts -nonewline ": "
        regsub -all "\n\n" $defn "\n: " defn
    }
    puts "$defn"
}
