#!/usr/bin/env perl

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use strict;
use warnings;
use v5.10;

use FindBin;
chdir $FindBin::Bin;

use Config::Tiny;
use Hash::Merge 'merge';
use JSON::Parse 'parse_json';

Hash::Merge::set_behavior('RIGHT_PRECEDENT');

use constant {
	STATE_TURBO_ALLOWED => 'ta',
	STATE_TURBO_DENIED => 'td'
};

my $config = load_config();
my $current_state = STATE_TURBO_ALLOWED;
switch_turbo(0);

while (1) {
	if ($current_state eq STATE_TURBO_ALLOWED && get_current_fan_rpm() > get_current_fan_limit()) {
		switch_turbo(1);
		$current_state = STATE_TURBO_DENIED;
		say "Switching off turbo mode."
	}
	if ($current_state eq STATE_TURBO_DENIED && get_current_fan_rpm() < get_current_fan_limit()) {
		switch_turbo(0);
		$current_state = STATE_TURBO_ALLOWED;
		say "Switching on turbo mode."
	}
	sleep(1);
}

# Use sensors command to fetch current speed of the monitored fan.
sub get_current_fan_rpm {
	my $sensors = `sensors -j`;
	chomp $sensors;
	$sensors = parse_json($sensors);
	for my $l (split (/\//, $config->{control}->{fan_path})) {
		$sensors = $sensors->{$l};
	}
	return $sensors;
}

# Get speed limit for the fan from configuration files.
sub get_current_fan_limit {
	return $config->{control}->{fan_limit};
}

# We load the intel_turbo_manager.default.yml configuration file and merge it with the local
# intel_turbo_manager.yml one if it exists.
sub load_config {
	die ("Missing intel_turbo_manager.default.yml file.") unless -f 'intel_turbo_manager.default.yml';
	my $config = Config::Tiny->read('intel_turbo_manager.default.yml');
	if (-f 'intel_turbo_manager.yml') {
		my $local_config = Config::Tiny->read('intel_turbo_manager.yml');
		$config = merge($config, $local_config);
	}
	return $config;
}

# Switch on or off the turbo mode by editing the no_turbo sys file depending of the
# provided parameter. Note that 0 enable the turbo and 1 disables it. It's quite 
# counter intuitive.
sub switch_turbo {
	my ($mode) = @_;
	die ('Invalid mode') unless $mode =~ /^0|1$/;
	open(FH, '>', '/sys/devices/system/cpu/intel_pstate/no_turbo')
		or die ('Can not open turbo controller');
	print FH $mode;
	close(FH);
}

=pod

=head1 NAME

Intel turbo manager

=head1 VERSION

1.0.0

=head1 DESCRIPTION

Switch on or off the turbo mode of your CPU depending of the current fan speed.
The purpose of this script is to find a compromise between performance and noise.

Read the intel_turbo_manager.default.yml file for knowing how to configure it.

=head1 AUTHORS

Kevin Hagner (Spydemon)

=head1 COPYRIGHT AND LICENSE

The MIT License (MIT)

Copyright 2020, Kevin Hagner (Spydemon)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
