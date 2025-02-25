#! /bin/sh
# Copyright (C) 2002-2023 Free Software Foundation, Inc.
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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Make sure Automake uses the _first_ @setfilname it sees.
# Report from Karl Berry.

. test-init.sh

cat > Makefile.am << 'END'
info_TEXINFOS = texinfo.texi
END

cat > texinfo.texi << 'END'
@setfilename texinfo.info
...
@verbatim
@setfilename example.info
@end verbatim
...
END

$ACLOCAL
$AUTOMAKE --add-missing

grep 'example' Makefile.in && exit 1
grep 'texinfo\.info:' Makefile.in

:
