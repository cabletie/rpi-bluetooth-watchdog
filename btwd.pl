#!/usr/bin/perl -w
#
# Bluetooth watchdog script
# Run from cron periodically to check bluetooth is talking to the SMA inverter.
# Restart bluetooth sussystem if not
# Peter Westley 1/12/2012 pjwestley@gmail.com
#

use warnings;
use strict;
use File::Basename;

# Print status to know we are running
print "$0: checking bluetooth status: ";

# Grab hci scan output and collect stderr as well
my $res=`hcitool scan 2>&1`;

# Test for matching the error condition
# Run bluetooth restart if bad result

if($res =~ m/inquiry failed/si) {
	print "Problem with bluetooth\n";
	print "Got result: $res\n";
	print "Reloading BT USB and restarting bluetooth subsystem\n";

	# The following little unbind/bind spell I found at:
	# http://davidjb.com/blog/2012/06/restartreset-usb-in-ubuntu-12-04-without-rebooting
	# The tee hoopla not strictly necessary but left it anyway.

	while (</sys/bus/usb/drivers/btusb/1*0>) {
		print "\nunbinding $_\n";
		my $dev = basename($_);
		print `echo -n $dev|tee /sys/bus/usb/drivers/btusb/unbind`;
		sleep 1;
		print "\nbinding $_\n";
		print `echo -n $dev|tee /sys/bus/usb/drivers/btusb/bind`;
	}
	# Now restart bluetooth subsystem
	print `/etc/init.d/bluetooth status 2>&1`;
	print `/etc/init.d/bluetooth restart 2>&1`;
}  else {
	print "OK\n";
}
