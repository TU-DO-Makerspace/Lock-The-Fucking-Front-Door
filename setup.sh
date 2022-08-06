#!/usr/bin/env bash

# Copyright (C) 2022 Patrick Pedersen, TUDO Makerspace

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Description: Installer/Uninstaller for ltffd-notify

# Time at which to notify users
HOUR="00"
MIN="00"

# Message to display
TITLE="Reminder"
TEXT="Lock the fucking front door!\n\nDue to past encounters with burglars, the TU-DO Makerspace door must be kept locked after ${HOUR}:${MIN}. Please close and lock the front door if it has not been done yet."

# Get directory of this script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR="$SCRIPT_DIR"

if [ "$EUID" -ne 0 ]
	then echo "setup.sh: Please run as root"
	exit
fi

install() {

	echo "setup.sh: Copying notify script (ltffd-notify) to /usr/local/bin"

	cp -v "$PROJECT_DIR/ltffd-notify" "/usr/local/bin/ltffd-notify"

	if [ ! -f "/usr/local/bin/ltffd-notify" ]
		then echo "setup.sh: Failed to copy notify script"
		exit
	fi

	chmod +x "/usr/local/bin/ltffd-notify"

	echo "setup.sh: Setting up cron job to notify users at $HOUR:$MIN"

	echo "$MIN $HOUR * * * root /usr/local/bin/ltffd-notify \"$TITLE\" \"$TEXT\"" > "/etc/cron.d/ltffd-notify"

	if [ $? -ne 0 ]; then
			echo "setup.sh: Cron job could not be added"
			rm -v -f "/usr/local/bin/ltffd-notify"
			echo "setup.sh: Setup failed"
	fi

	echo "setup.sh: Setup complete"
}

uninstall() {
	
	echo "setup.sh: Removing cron job"
	rm -v -f "/etc/cron.d/ltffd-notify"

	echo "setup.sh: Removing notify script"
	rm -v -f "/usr/local/bin/ltffd-notify"

	echo "setup.sh: Uninstall complete"
}

if [ "$1" == "uninstall" ]; then
	uninstall
elif [ -z $1 ]; then
	install
else
	echo "setup.sh: Usage: setup.sh [uninstall]"
fi