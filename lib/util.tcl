# Copyright (c) 2012 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# Module which contains miscellaneous utility functions

# @compare-versions version1 version2
#
# Versions are of the form 'a.b.c' (may be any number of numeric components)
#
# Compares the two versions and returns:
## -1 if v1 < v2
##  0 if v1 == v2
##  1 if v1 > v2
#
# If one version has fewer components than the other, 0 is substituted to the right. e.g.
## 0.2   <  0.3
## 0.2.5 >  0.2
## 1.1   == 1.1.0
#
proc compare-versions {v1 v2} {
	foreach c1 [split $v1 .] c2 [split $v2 .] {
		if {$c1 eq ""} {
			set c1 0
		}
		if {$c2 eq ""} {
			set c2 0
		}
		if {$c1 < $c2} {
			return -1
		}
		if {$c1 > $c2} {
			return 1
		}
	}
	return 0
}

# @suffix suf list
#
# Takes a list and returns a new list with '$suf' appended
# to each element
#
## suffix .c {a b c} => {a.c b.c c.c}
#
proc suffix {suf list} {
	set result {}
	foreach p $list {
		lappend result $p$suf
	}
	return $result
}

# @prefix pre list
#
# Takes a list and returns a new list with '$pre' prepended
# to each element
#
## prefix jim- {a.c b.c} => {jim-a.c jim-b.c}
#
proc prefix {pre list} {
	set result {}
	foreach p $list {
		lappend result $pre$p
	}
	return $result
}
