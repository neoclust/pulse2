#!/bin/bash -e

#
# (c) 2004-2007 Linbox / Free&ALter Soft, http://linbox.com
# (c) 2007-2009 Mandriva, http://www.mandriva.com
#
# $Id$
#
# This file is part of Mandriva Management Console (MMC).
#
# MMC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# MMC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with MMC.  If not, see <http://www.gnu.org/licenses/>.

# bootstrap.sh [target]
# Main entry point to automatically perform a basic Pulse setup using code
# from the SVN.
# If target is specified, the Pulse 2 main Makefile will be called with this
# target.

# Install script won't ask user confirmation when FORCE=1
export FORCE=1

export TMPCO=`mktemp -d`

pushd $TMPCO

# Uninstall Pulse 2
svn co http://mds.mandriva.org/svn/mmc-projects/pulse2/server/trunk pulse2
export PULSE2="$TMPCO/pulse2"
pushd $PULSE2/tests/scripts
./uninstall.sh
popd

svn co http://mds.mandriva.org/svn/mmc-projects/mmc-core/trunk mmc-core
export MMCCORE="$TMPCO/mmc-core"
pushd $MMCCORE/tests/scripts
./uninstall.sh
./install.sh
popd

pushd $PULSE2/tests/scripts
./install.sh || true
popd

# Call makefile target if specified
if [ ! -z "$1" ];
    then
    pushd $PULSE2
    make "$1" || true
    popd
fi

popd

rm -fr $TMPCO

exit 0
