# Module for handling level.env_mod stalker files
# Update history:
#	03/11/2014 - initial release
##################################################
package stkutils::level::level_env_mod;
use strict;
use stkutils::data_packet;
use stkutils::ini_file;
use stkutils::debug qw(fail);

sub new {
	my $class = shift;
	my $self = {};
	$self->{config} = {};
	$self->{env_mods} = [];
	bless $self, $class;
	return $self;
}
sub get_src {return $_[0]->{config}->{src}}
sub mode {return $_[0]->{config}->{mode}}
sub read {
	my $self = shift;
	my ($CDH) = @_;
	my $expected_index = 0;
	while (1) {
		my ($index, $size) = $CDH->r_chunk_open();
		defined $index or last;
		fail('chunk '.$index.' have unproper index') unless $expected_index == $index;
		
		my $packet = stkutils::data_packet->new($CDH->r_chunk_data());
		my $env_mod = env_mod->new();
		$env_mod->read($packet);
		fail('there is some data left in packet: '.$packet->resid()) unless $packet->resid() == 0;
		push @{$self->{env_mods}}, $env_mod;
		$expected_index++;
		
		$CDH->r_chunk_close();
	}
}
sub write {
	my $self = shift;
	my ($CDH) = @_;
	my $index = 0;
	foreach my $env_mod (@{$self->{env_mods}}) {
		my $packet = stkutils::data_packet->new();
		$env_mod->write($packet);
		$CDH->w_chunk($index, $packet->data());
		$index++;
	}
}
sub my_import {
	my $self = shift;
	my $IFH = stkutils::ini_file->new($_[0], 'r') or die;
	foreach my $section (@{$IFH->{sections_list}}) {
		my $env_mod = env_mod->new();
		$env_mod->import($IFH, $section);
		push @{$self->{env_mods}}, $env_mod;
	}
	$IFH->close()
}
sub export {
	my $self = shift;
	my $IFH = stkutils::ini_file->new($_[0], 'w') or die;
	my $RFH = $IFH->{fh};
	my $index = 0;
	foreach my $env_mod (@{$self->{env_mods}}) {
		print $RFH "[$index]\n";
		$env_mod->export($IFH);
		print $RFH "\n";
		$index++;
	}
	$IFH->close()
}
#######################################################################
package env_mod;
use strict;

use constant properties_info => (
	{ name => 'position',		type => 'f32v3'},
	{ name => 'radius',			type => 'f32' },
	{ name => 'power',			type => 'f32' },
	{ name => 'far_plane',		type => 'f32' },
	{ name => 'fog_color',		type => 'f32v3' },
	{ name => 'fog_density',	type => 'f32' },
	{ name => 'ambient',		type => 'f32v3' },
	{ name => 'sky_color',		type => 'f32v3' },
	{ name => 'hemi_color',		type => 'f32v3' },
);
sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}
sub read {
	$_[1]->unpack_properties($_[0], properties_info);
}
sub write {
	$_[1]->pack_properties($_[0], properties_info);
}
sub import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub export {
	$_[1]->export_properties(undef, $_[0], properties_info);
}
#######################################################################
1;