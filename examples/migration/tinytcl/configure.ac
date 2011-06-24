#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.57)
AC_INIT([tinytcl], [6.8.0], [steveb@workware.net.au])

AC_SUBST(TARGET_PLATFORM,$ac_cv_host)

# Checks for programs.
AC_PROG_CC
AC_PROG_MAKE_SET

TINYTCL_IS_STATIC=1
AC_ARG_ENABLE(shared,
	[  --enable-shared         Build a shared library],
	[
		if test "x$enableval" = "xyes" ; then
			AC_MSG_RESULT(* creating shared library)
			TINYTCL_IS_STATIC=
		fi
	]
)
AC_SUBST(TINYTCL_IS_STATIC,$TINYTCL_IS_STATIC)

AC_ARG_ENABLE(history,
	[  --enable-history        Enable history support],
	[
		if test "x$enableval" = "xyes" ; then
			AC_MSG_RESULT(* enabling history)
			TINYTCL_HISTORY=1
		fi
	],
)
AC_SUBST(TINYTCL_HISTORY,$TINYTCL_HISTORY)

AC_ARG_ENABLE(debug,
	[  --enable-debug          Enable debugging command: cmdtrace],
	[
		if test "x$enableval" = "xyes" ; then
			AC_MSG_RESULT(* enabling debugging)
			TINYTCL_DEBUG=1
		fi
	],
)
AC_SUBST(TINYTCL_DEBUG,$TINYTCL_DEBUG)

AC_ARG_ENABLE(fork,
	[  --disable-fork          Do not use fork (no exec, etc.)],
	[
		if test "x$enableval" = "xno" ; then
			AC_MSG_RESULT(* disabling fork)
			TINYTCL_NOFORK=1
		fi
	],
)
AC_SUBST(TINYTCL_NOFORK,$TINYTCL_NOFORK)

AC_ARG_ENABLE(syslog,
	[  --enable-syslog         Build the syslog extension],
	[
		if test "x$enableval" = "xyes" ; then
			AC_MSG_RESULT(* enabling extension: syslog)
			TINYTCL_EXTENSIONS="$TINYTCL_EXTENSIONS syslog"
		fi
	],
)

AC_SUBST(TINYTCL_EXTENSIONS,$TINYTCL_EXTENSIONS)

AC_CHECK_LIB(dl, dlopen)
if test $ac_cv_lib_dl_dlopen = yes; then
	AC_SUBST(LIBDL,-ldl)
fi

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
