# Solaris flash - backup tool
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/yvoinov/solaris-flash/blob/main/LICENSE)
____________________________________________________________
This script is written for Flar-archives level 0 of root fs or root pool creation. Flar-archives can be used for bare-metal restore and systems cloning purposes.

Script can execute in interactive or non-interactive modes.

When calls without parameters it runs in interactive mode and asks for directory (mountpoint) for which flar can be save.

For non-interactive calls you must specify mountpoint as command-line argument.

If you specify /?, /h, /help и help as argument, you can see usage page.

Archive names will be generated as follows:

[hostname][level].flar, where [hostname] - host machine name, [level] - archive level (0 by default - full).

If archive with generated name is exists in target mountpoint, script generates new incremental archive name as follows:

[hostname][level].flar, где n=1,2,3....

Archive author gets from USER environment variable.

Supports Solaris 10 10/09 and above zflash functionality: flar-archive from ZFS root pool for Jump Start flash installation.
____________________________________________________________
Copyright (C) 2007-2009 Yuri Voinov