#! /usr/bin/perl

# update.pl
# This file downloads the latest level 1 and 2 lists from iblocklist.com,
# converts them into a format usable by uTorrent and writes them into the
# ipfilter.dat file for uTorrent.
# This is setup for mac at the moment but all you need to do is change the
# location of the ipfilter.dat file (held in variable $full_list_file) to 
# the location appropriate for your setup/platform.
# You can check if the IP's have been loaded by uTorrent by going to 
# Window -> 'Message log' in the uTorrent application window. It should say
# 'Loaded ipfilter.dat (xxxxx entries)' where xxxxx is some number.

use strict;
use warnings;
use LWP::Simple qw(mirror);
use IO::Uncompress::Gunzip qw(gunzip);
use Getopt::Long;

my $url_prefix = 'http://list.iblocklist.com/?list=bt_level';
my $url_postfix = '&fileformat=p2p&archiveformat=gz';
my $filename_prefix =  'level';
my $filename_postfix = '.gz';
my $full_list_file = "$ENV{'HOME'}/Library/Application Support/uTorrent/ipfilter.dat";
my $full_list_fp = undef;
my $top_level = 0;
my $usage =  <<CAT
Usage:
update.pl [--level=num]

--level=num:    Num is the list level you would like to download
                which is either 1, 2 or 3, 3 being the
                greatest level of IP blocking. The default level is 2.
CAT
;

GetOptions ('level=i' => \$top_level);

# extract the level provided by the user, if any

if ($top_level == 0)
{
    print "Using default level 2\n";
    $top_level = 2;
}
else
{
    # check to see if value given for level is appropriate
    for($top_level)
    {
        if(/1/) {last;}
        if(/2/) {last;}
        if(/3/) {last;}
        die "$usage\n";
    }
}

# get the zip file and store it
foreach my $level ( 1 .. $top_level )
{
    my $zip_file = $filename_prefix . $level . $filename_postfix;
    my $list_file = $level . ".dat";
    my $url = $url_prefix . $level . $url_postfix;
    print "Downloading file $zip_file now\n";
    my $status = mirror($url, $zip_file);
    
    if ($status == 304)
    {
        # this list has not been modified since last update
        print "List level$level has not been modified...\n";
    }
    elsif ($status != 200)
    {
        # dont need to update/unable to update the list
        die "Download returned status $status";
    }
    
    print "Download OK, now unzipping\n";
    gunzip($zip_file,$list_file) or die "Unable to unzip file!";
    
    if(not defined $full_list_fp)
    {
        unlink $full_list_file;
        open($full_list_fp,'>',$full_list_file) or die "Unable to open $full_list_file";
    }
    
    my $list_fp;
    open($list_fp, '<', $list_file) or die "Unable to open $list_file";

    # copy all ip's to new file
    while (<$list_fp>)
    {
        # dont try and add comments
        if(m/^#/)
        {
            next;
        }
        my ($name,$ip) = split /:/;
        
        # some IP's end up here, so add them and let uTorrent decide if it likes them
        if (not defined $ip)
        {
            print $full_list_fp $_;
            next;
        }
        print $full_list_fp $ip;
    }

    close $list_fp;
    unlink $list_file;
}

if( defined $full_list_fp) 
{
    close $full_list_fp;
}

# DONE!

print "DONE!\n";
