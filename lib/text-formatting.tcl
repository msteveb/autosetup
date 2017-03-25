# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which provides text formatting

use formatting

proc wordwrap {text length {firstprefix ""} {nextprefix ""}} {
	set len 0
	set space $firstprefix

	foreach word [split $text] {
		set word [string trim $word]
		if {$word eq ""} {
			continue
		}
		if {[info exists partial]} {
			append partial " " $word
			if {[string first $quote $word] < 0} {
				# Haven't found end of quoted word
				continue
			}
			# Finished quoted word
			set word $partial
			unset partial
			unset quote
		} else {
			set quote [string index $word 0]
			if {$quote in {' *}} {
				if {[string first $quote $word 1] < 0} {
					# Haven't found end of quoted word
					# Not a whole word.
					set first [string index $word 0]
					# Start of quoted word
					set partial $word
					continue
				}
			}
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
		if {[regexp {^'(.*)'(.*)} $word -> quoted after]} {
			set quoted [string map {~ " "} $quoted]
			regsub -all . $quoted "&\b&" quoted
			set word $quoted$after
		} elseif {[regexp {^[*](.*)[*](.*)} $word -> quoted after]} {
			set quoted [string map {~ " "} $quoted]
			regsub -all . $quoted "_\b&" quoted
			set word $quoted$after
		}
		puts -nonewline $space$word
		set space " "
	}
	if {[info exists partial]} {
		# Missing end of quote
		puts -nonewline $space$partial
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
proc codelines {lines} {
	foreach line $lines {
		puts "	  $line"
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
	underline "[string trim $text]" -
	nl
}
proc subsection {text} {
	underline "$text" ~
	nl
}
proc bullet {text} {
	wordwrap $text 76 "	 * " "	  "
}
proc indent {text} {
	wordwrap $text 76 "	   " "	  "
}
proc defn {first args} {
	if {$first ne ""} {
		underline "	   $first" ~
	}
	foreach p $args {
		if {$p ne ""} {
			indent $p
		}
	}
}
