#
# (c) 2008 Mandriva, http://www.mandriva.com/
#
# $Id: setup.py 771 2009-05-19 16:37:01Z nrueff $
#
# This file is part of Pulse 2, http://pulse2.mandriva.org
#
# Pulse 2 is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Pulse 2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pulse 2; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

from distutils.core import setup

setup(
    name = "pulse2",
    version = "1.2.2",
    url = "http://www.mandriva.com",
    author = "Cedric Delfosse",
    author_email = "cdelfosse@mandriva.com",
    maintainer = "Cedric Delfosse",
    maintainer_email = "cdelfosse@mandriva.com",
    packages = ["mmc", "mmc.plugins",
        "mmc.plugins.dyngroup", "mmc.plugins.dyngroup.querymanager",
        "mmc.plugins.glpi", "mmc.plugins.glpi.querymanager",
        "mmc.plugins.imaging",
        "mmc.plugins.pulse2",
        "mmc.plugins.pkgs",
        "mmc.plugins.inventory", "mmc.plugins.inventory.querymanager",
        "mmc.plugins.inventory.provisioning_plugins",
        "mmc.plugins.inventory.provisioning_plugins.network_to_entity",
        "mmc.plugins.msc", "mmc.plugins.msc.client",
	"pulse2", "pulse2.managers", "pulse2.apis", "pulse2.apis.clients", "pulse2.inventoryserver", "pulse2.launcher", 
       	"pulse2.database", "pulse2.database.inventory", "pulse2.database.dyngroup", "pulse2.database.msc", "pulse2.database.msc.orm",
	"pulse2.scheduler",
        "pulse2.scheduler.assign_algo",
        "pulse2.scheduler.assign_algo.default",
        "pulse2.scheduler.assign_algo.ip_class",
        "pulse2.scheduler.cache",
        "pulse2.scheduler.tracking",
        "pulse2.package_server",
        "pulse2.package_server.common",
        "pulse2.package_server.description",
        "pulse2.package_server.mirror_api",
        "pulse2.package_server.package_api_get",
        "pulse2.package_server.mirror",
        "pulse2.package_server.package_api_put",
        "pulse2.package_server.scheduler_api",
        "pulse2.package_server.user_package_api",
        "pulse2.package_server.assign_algo",
        "pulse2.package_server.assign_algo.default",
        "pulse2.package_server.assign_algo.terminal_type"
],
)

