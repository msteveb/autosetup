# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides common text formatting

# This is designed for documenation which looks like:
# code {...}
# or
# code {
#    ...
#    ...
# }
# In the second case, we need to work out the indenting
# and strip it from all lines but preserve the remaining indenting.
# Note that all lines need to be indented with the same initial
# spaces/tabs.
#
# Returns a list of lines with the indenting removed.
#
proc parse_code_block {text} {
    # If the text begins with newline, take the following text,
    # otherwise just return the original
    if {![regexp "^\n(.*)" $text -> text]} {
        return [list [string trim $text]]
    }

    # And trip spaces off the end
    set text [string trimright $text]

    set min 100
    # Examine each line to determine the minimum indent
    foreach line [split $text \n] {
        if {$line eq ""} {
            # Ignore empty lines for the indent calculation
            continue
        }
        regexp "^(\[ \t\]*)" $line -> indent
        set len [string length $indent]
        if {$len < $min} {
            set min $len
        }
    }

    # Now make a list of lines with this indent removed
    set lines {}
    foreach line [split $text \n] {
        lappend lines [string range $line $min end]
    }

    # Return the result
    return $lines
}
