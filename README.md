# Blocklist Updater for uTorrent

This small perl script simply updates the blocklist for uTorrent (where no automatic software is available, such as PeerBlock). It is currently set up for Mac OSX assuming a default installation of uTorrent but it's VERY easy to change the script to suit your own setup.

## Setup for Systems other than OSX

All you need to do is change the location of the ipfilter.dat file in the script. The location is defined in the variable `$full_list_file`.
