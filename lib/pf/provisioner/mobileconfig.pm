package pf::provisioner::mobileconfig;
=head1 NAME

pf::provisioner::mobileconfig add documentation

=cut

=head1 DESCRIPTION

pf::provisioner::mobileconfig

=cut

use strict;
use warnings;
use Moo;
extends 'pf::provisioner';

=head1 Atrributes

=head2 oses

The set the default OS to IOS

=cut

has oses => (is => 'rw', default => sub { ['Apple iPod, iPhone or iPad'] });

=head2 ssid

The ssid

=cut

has ssid => (is => 'rw');

=head2 ca_cert_path

The ca cert_path

=cut

has ca_cert_path => (is => 'rw');

# make it skip deauth by default 
has skipDeAuth => (is => 'rw', default => sub{ 1 });

has for_username => (is => 'rw');

=head1 METHODS

=head2 authorize

always authorize

=cut

sub authorize { 
    my ($self, $mac) = @_;
    my $info = pf::node::node_view($mac);
    $self->for_username($info->{pid});
    return 1;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
