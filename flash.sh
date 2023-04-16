#!/sbin/sh

#
# Full Flash archive creation script.
#
# Archives uses for bare-metal recovery
# and systems cloning.
#
# Archive file names will be incremental
# as: <hostname><level>_n.flar, n=1,2...
#
# Version 1.4 (C) 2007-2009 Y.Voinov
#
# If you specify destination directory
# in command line, script will run in
# non-interactive mode.
#
# ident "@(#)flash.sh   1.4   10/22/09 YV"
#

#############
# Variables #
#############

# Flash attributes
author="$USER"
# Archive destination
dest=""
# Archive level. "0" means full
lvl="0"
# Compress archive with compress utility. Leave blank if not
compress="-c"
# Archive extension
ext="flar"
# ZFlash snapshot name template
zflash_name="zflash"

# OS utilities
CUT=`which cut`
ECHO=`which echo`
FLAR=`which flar`
GREP=`which grep`
HOSTNAME=`which hostname`
ID=`which id`
LS=`which ls`
PRINTF=`which printf`
UNAME=`which uname`
WHOAMI=`which whoami`
ZFS=`which zfs`

OS_VER=`$UNAME -r|$CUT -f2 -d"."`
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
OS_FULL=`$UNAME -sr`

# System attributes and flar description
system=`$HOSTNAME`
desc="$system full flash"

###############
# Subroutines #
###############

check_os ()
{
 # Check OS
 $PRINTF "Checking OS... "
 if [ "$OS_NAME" = "SunOS" -a "$OS_VER" -lt "9" ]; then
  $ECHO "ERROR: Unsupported OS: $OS_FULL"
  $ECHO "Exiting..."
  exit 1
 else
  $ECHO "$OS_FULL"
 fi
}

check_root ()
{
 # Check if user root
 $PRINTF "Checking super-user... "
 if [ -f /usr/xpg4/bin/id ]; then
  WHO=`/usr/xpg4/bin/id -n -u`
 elif [ "`$ID | $CUT -f1 -d" "`" = "uid=0(root)" ]; then
  WHO="root"
 else
  WHO=$WHOAMI
 fi

 if [ ! "$WHO" = "root" ]; then
  $ECHO "ERROR: You must be super-user to run this script."
  exit 1
 fi
 $ECHO "$WHO"
}

archive_exists ()
{
 # Check archive file exist
 if [ -f "$file"."$ext" ]; then
  $ECHO "1"
 else
  $ECHO "0"
 fi
}

set_file ()
{
 # Check archive name exists and create new name if any
 attempt=0

 while [ "`archive_exists`" = "1" ]; do
  attempt=`expr $attempt + 1`
  file=`$ECHO $file|$CUT -f1 -d"_"`
  file="$file"_"$attempt"
  if [ "`archive_exists`" != "1" ]; then
   break
  fi
 done
}

check_dest_dir ()
{
 # Check directory exist and it permissions
 arg_dest=$1
 
 if [ ! -d "$arg_dest" or ! -w "$arg_dest" ]; then
  $ECHO "ERROR: Directory you specified does not exist"
  $ECHO "       or you haven't permissions to write."
  $ECHO "Exiting..."
  exit 1
 fi 
}

check_non_interactive ()
{
 # Check if script runs in non-interactive mode
 arg1=$1
 
 # If script command-line argument not specify,
 # then run in interactive mode
 if [ "x$arg1" = "x" ]; then
 
  $ECHO "---------------------------------------"
  $ECHO "$system full flash archive creation"
  $ECHO "---------------------------------------"
  $ECHO
  $ECHO ">>> Press <Enter> to continue or"
  $ECHO ">>> Press <Ctrl+C> to cancel operation."
  $ECHO
  read p

  # Read directory/mount point to flash
  $ECHO "Input archive destination mount point"
  $PRINTF "and press enter: "
  read dest
 
  # Check destination directory
  check_dest_dir $dest
  
 elif [ "x$arg1" = "x/?" -o "x$arg1" = "x/h" -o "x$arg1" = "x/help" -o "x$arg1" = "xhelp" ]; then
  $ECHO "Usage: $0 calls script in interactive mode."
  $ECHO "       or"
  $ECHO "       $0 <destination directory for archive>"
  $ECHO "       calls script in non-interactive mode."
  $ECHO
  $ECHO "Note: Archives compressed by default."
  exit 0
  
 else
  # If script command-line argument specified,
  # run in non-interactive mode
  dest=$arg1
  # Check destination directory
  check_dest_dir $dest
 fi
}

destroy_zflash_if_any ()
{
 # Destroy zflash snapshots if any
 for c in `$ZFS list -H -o name -t snapshot|$GREP $zflash_name`
 do
  $ZFS destroy $c
 done
}

##############
# Main block #
##############

# Checking OS
check_os

# Checking root
check_root

# Check non-interactive mode
check_non_interactive $1

# Check compression parameter 
if [ -z "$compress" ]; then
 $ECHO "*** Compression will NOT be used."
else
 $ECHO "*** Archive will be compressed."
fi

# Set initial archive file name
file="$dest"/"$system""$lvl"

# Check archive name exists
# and create new incremental name
set_file

# Destroy zflash snapshots if any created
destroy_zflash_if_any

# Create full initial flash. Compression will set by default,
# can be changed optionally
$FLAR create -a "$author" -e "$desc" "$compress" -n "$system""$lvl" "$file"."$ext"

# Destroy zflash snapshots if any created
destroy_zflash_if_any

# Show final archive and it's size
$ECHO "---------------------------------------"
$ECHO "Creation complete."
$ECHO "Archive size is:"
$LS -ls "$file"."$ext"

exit 0
