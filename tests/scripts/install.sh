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

export LANG=C
export LC_ALL=C

echo "Pulse2 auto-installation script"
echo

if [ ! -f "/etc/init.d/mmc-agent" ];
then
    echo "Please install MMC CORE first."
    exit 1
fi

if [ ! -f "/bin/lsb_release" ];
then
    echo "Please install lsb_release."
    echo "urpmi lsb-release"
    exit 1
fi

DISTRIBUTION=`lsb_release -i -s`
RELEASE=`lsb_release -r -s`

PKGS=

if [ `arch` == "x86_64" ];
then
    ARCH=64
else
    ARCH=
fi

function packages_to_install () {
    # MySQL
    PKGS="$PKGS mysql mysql-client"
    if [ $RELEASE == "2010.0" ];
        then
        PKGS="$PKGS python-mysql"
    fi
}

if [ ! -f "$DISTRIBUTION-$RELEASE" ];
then
    echo "This version of Operating System ($DISTRIBUTION-$RELEASE) is not supported"
    exit 1
fi

if [ -z $FORCE ];
    then
    echo
    echo "WARNING: this script will erase some parts of your configuration !"
    echo "         type Ctrl-C now to exit if you are not sure"
    echo "         type Enter to continue"
    read
fi

packages_to_install
urpmi --auto --no-suggests $PKGS
rpm -q $PKGS

if [ -z $TMPCO ];
    then
    TMPCO=`mktemp -d`
    TMPREMOVE=1
    pushd $TMPCO
    # Check out Pulse 2 source
    svn co https://mds.mandriva.org/svn/mmc-projects/pulse2/server/trunk pulse2
else
    pushd $TMPCO
fi

pushd pulse2
make install PREFIX=/usr
popd

popd

IPADDRESS=`ifconfig eth0 | grep 'inet ' | awk '{print $2}' | sed 's/addr://'`
echo "My IP address is $IPADDRESS"

export MYSQL_HOST=localhost
export MYSQL_USER=root
export MYSQL_PWD=
# Create database msc and configure msc.init

pushd $TMPCO/pulse2/services/contrib/msc/sql/
export MYSQL_BASE=msc
./install.sh
sed -i "s/#\[main\]/\[main\]/" /etc/mmc/plugins/msc.ini
sed -i "s/# disable = 0/disable = 0/" /etc/mmc/plugins/msc.ini
sed -i "s/# mserver = 127.0.0.1/mserver = $IPADDRESS/" /etc/mmc/plugins/msc.ini
sed -i "/\[scheduler_api\]/{n; s/host = 127.0.0.1/host = $IPADDRESS/}" /etc/mmc/plugins/msc.ini

# Create database dyngroup and configure dyngroup.init
pushd $TMPCO/pulse2/services/contrib/dyngroup/sql/
export MYSQL_BASE=dyngroup
./install.sh
sed -i "s/# default_module = /default_module = inventory/" /etc/mmc/plugins/dyngroup.ini
sed -i "s/activate = 0/activate = 1/" /etc/mmc/plugins/dyngroup.ini
popd

# Create database inventory and configure inventory.init
pushd $TMPCO/pulse2/services/contrib/inventory/sql/
export MYSQL_BASE=inventory
./install.sh
sed -i "s/disable = 1/disable = 0/" /etc/mmc/plugins/inventory.ini
sed -i "s/# \[querymanager\]/\[querymanager\]/" /etc/mmc/plugins/inventory.ini
sed -i "s/# list =/list =/" /etc/mmc/plugins/inventory.ini
sed -i "s/# double =/double =/" /etc/mmc/plugins/inventory.ini
sed -i "s/# halfstatic =/halfstatic =/" /etc/mmc/plugins/inventory.ini
popd

# Create database inventory and configure inventory.init
pushd $TMPCO/pulse2/services/contrib/imaging/sql/
export MYSQL_BASE=imaging
./install.sh
popd

mysql << EOF
GRANT ALL PRIVILEGES ON msc.* TO 'mmc'@'localhost'
IDENTIFIED BY 'mmc' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON dyngroup.* TO 'mmc'@'localhost'
IDENTIFIED BY 'mmc' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON inventory.* TO 'mmc'@'localhost'
IDENTIFIED BY 'mmc' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON imaging.* TO 'mmc'@'localhost'
IDENTIFIED BY 'mmc' WITH GRANT OPTION;
FLUSH PRIVILEGES
EOF

# configure base.ini

sed -i "s/# \[computers\]/\[computers\]/" /etc/mmc/plugins/base.ini
sed -i "s/# method = inventory/method = inventory/" /etc/mmc/plugins/base.ini

# create the temp folder for packages
mkdir -p /tmp/package_tmp/put1/test1
mkdir -p /tmp/package_tmp/put1/test2

sed -i "6s/^# host =/host = $IPADDRESS/" /etc/mmc/pulse2/package-server/package-server.ini
sed -i "s/# \[imaging_api\]/\[imaging_api\]/" /etc/mmc/pulse2/package-server/package-server.ini
UUID=`uuidgen`
sed -i "s/# uuid = PLEASE_PUT_A_UUID_FOR_THAT_SERVER/uuid = $UUID/" /etc/mmc/pulse2/package-server/package-server.ini

# Config pkgs.ini
sed -i "s/server = localhost/server = $IPADDRESS/" /etc/mmc/plugins/pkgs.ini

# Generate SSH key if not available
if [ ! -f /root/.ssh/id_dsa ];
then
    ssh-keygen -t dsa -f /root/.ssh/id_dsa -N ""
    # Allow SSH connection without password on localhost
    cat /root/.ssh/id_dsa.pub > /root/.ssh/authorized_keys
fi

# Launch all service of Pulse 2
echo "Launch Pulse 2's services"
/etc/init.d/pulse2-package-server restart
/etc/init.d/pulse2-launchers restart
/etc/init.d/pulse2-scheduler restart

# Launch mmc-agent
/etc/init.d/mmc-agent force-stop
rm -f /var/run/mmc-agent.pid
/etc/init.d/mmc-agent start

if [ ! -z $TMPREMOVE ];
    then
    rm -fr $TMPCO
fi

echo "Installation done successfully"
exit 0
