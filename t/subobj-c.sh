#! /bin/sh
# Copyright (C) 1999-2013 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Test subdir objects with C, building both a library and an executable.
# Keep in sync with sister test 'subobj-cxx.sh'.

required=cc
. test-init.sh

cat >> configure.ac << 'END'
AC_PROG_CC
AM_PROG_AR
AC_PROG_RANLIB
AC_OUTPUT
END

cat > Makefile.am << 'END'
bin_PROGRAMS = progs/wish
lib_LIBRARIES = libs/libhope.a
progs_wish_SOURCES = generic/a.c generic/b.c
libs_libhope_a_SOURCES = sub/sub2/foo.c

.PHONY: remake-single-object
remake-single-object:
	rm -rf generic
	$(MAKE) generic/a.$(OBJEXT)
	test -f generic/a.$(OBJEXT)
	test ! -f generic/b.$(OBJEXT)
	rm -rf generic
	$(MAKE) generic/b.$(OBJEXT)
	test ! -f generic/a.$(OBJEXT)
	test -f generic/b.$(OBJEXT)
	rm -rf sub generic
	$(MAKE) sub/sub2/foo.$(OBJEXT)
	test -f sub/sub2/foo.$(OBJEXT)
	test ! -d generic
END

mkdir generic sub sub/sub2

cat > generic/a.c <<END
int main (void)
{
  extern int i;
  return i;
}
END
echo 'int i = 0;' > generic/b.c

cat > sub/sub2/foo.c <<'END'
int answer (void)
{
  return 42;
}
END

rm -f compile # We want to check '--add-missing' installs this.

$ACLOCAL
$AUTOMAKE --add-missing 2>stderr || { cat stderr >&2; exit 1; }
cat stderr >&2

# Make sure compile is installed, and that Automake says so.
grep '^configure\.ac:7:.*install.*compile' stderr
test -f compile

$EGREP '[^/](a|b|foo)\.\$(OBJEXT)' Makefile.in && exit 1

$AUTOCONF

mkdir build
cd build
../configure
$MAKE

test -d progs
test -d libs
test -d generic
test -d sub/sub2

if test -f progs/wish; then
  EXEEXT=
elif test -f progs/wish.exe; then
  EXEEXT=.exe
else
  fatal_ "couldn't determine extension of executables"
fi

# The libraries and executables are not uselessly remade.
: > xstamp
$sleep
echo dummy > progs/change-dir-timestamp
echo dummy > libs/change-dir-timestamp
echo dummy > generic/change-dir-timestamp
echo dummy > sub/change-dir-timestamp
echo dummy > sub/sub2/change-dir-timestamp
$MAKE
is_newest xstamp progs/wish$EXEEXT libs/libhope.a

$MAKE remake-single-object

# Must work also with dependency tracking disabled.
# Also sanity check the distribution.
$MAKE distcheck DISTCHECK_CONFIGURE_FLAGS=--disable-dependency-tracking

: