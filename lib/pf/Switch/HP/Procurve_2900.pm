package pf::Switch::HP::Procurve_2900;

=head1 NAME

pf::Switch::HP::Procurve_2900 - Object oriented module to access SNMP enabled HP Procurve 2900 switches

=head1 SYNOPSIS

The pf::Switch::HP::Procurve_2900 module implements an object
oriented interface to access SNMP enabled HP Procurve 2900 switches.

=head1 BUGS AND LIMITATIONS

VoIP not tested using MAC Authentication/802.1X

=cut

use strict;
use warnings;
use Log::Log4perl;
use Net::SNMP;
use base ('pf::Switch::HP');

sub description { 'HP ProCurve 2900 Series' }

# importing switch constants
use pf::Switch::constants;
use pf::util;
use pf::config;

# CAPABILITIES
# access technology supported
sub supportsWiredMacAuth { return $TRUE; }
sub supportsWiredDot1x { return $TRUE; }
# inline capabilities
sub inlineCapabilities { return ($MAC,$PORT); }
sub supportsLldp { return $TRUE; }
=item supportsRadiusVoip
This switch module supports VoIP authorization over RADIUS.
Use getVoipVsa to return specific RADIUS attributes for VoIP to work.
=cut
sub supportsRadiusVoip { return $TRUE; }

=item getVoipVsa {
Returns RADIUS attributes for voip phone devices.
=cut
sub getVoipVsa {
        my ( $this ) = @_;
        my $logger = Log::Log4perl::get_logger(ref($this));
        return (
                'Tunnel-Type' => $RADIUS::VLAN,
                'Tunnel-Medium-Type' => $RADIUS::ETHERNET,
                'Tunnel-Private-Group-ID' => $this->getVlanByName('voice'),
                );
}
=item isVoIPEnabled
Supports VoIP if enabled.
=cut
sub isVoIPEnabled {
        my ($self) = @_;
        return ( $self->{_VoIPEnabled} == 1 );
}

=item getPhonesLLDPAtIfIndex
Using SNMP and LLDP we determine if there is VoIP connected on the switch port
=cut
sub getPhonesLLDPAtIfIndex {
        my ( $this, $ifIndex ) = @_;
        my $logger = Log::Log4perl::get_logger( ref($this) );
        my @phones;
        if ( !$this->isVoIPEnabled() ) {
                $logger->debug( "VoIP not enabled on switch "
                        . $this->{_ip}
                        . ". getPhonesLLDPAtIfIndex will return empty list." );
                return @phones;
        }
        my $oid_lldpRemPortId = '1.0.8802.1.1.2.1.4.1.1.7';
        my $oid_lldpRemChassisIdSubtype = '1.0.8802.1.1.2.1.4.1.1.4';
        if ( !$this->connectRead() ) {
                return @phones;
        }
        sleep(4);
        $logger->trace(
                "SNMP get_next_request for lldpRemChassisIdSubtype: $oid_lldpRemChassisIdSubtype");
        my $result = $this->{_sessionRead}
        ->get_table( -baseoid => $oid_lldpRemChassisIdSubtype );
        foreach my $oid ( keys %{$result} ) {
                if ( $oid =~ /^$oid_lldpRemChassisIdSubtype\.([0-9]+)\.([0-9]+)\.([0-9]+)$/ ) {
                        if ( $ifIndex eq $2 ) {
                                my $cache_lldpRemTimeMark = $1;
                                my $cache_lldpRemLocalPortNum = $2;
                                my $cache_lldpRemIndex = $3;
                                if ( $result->{$oid} =~ /5/i ) {
                                        $logger->trace(
                                                "SNMP get_request for lldpRemPortId: $oid_lldpRemPortId.$cache_lldpRemTimeMark.$cache_lldpRemLocalPortNum.$cache_lldpRemIndex"
                                                );
                                        my $MACresult = $this->{_sessionRead}->get_request(
                                                -varbindlist => [
                                                "$oid_lldpRemPortId.$cache_lldpRemTimeMark.$cache_lldpRemLocalPortNum.$cache_lldpRemIndex"
                                                ]
                                                );
                                        if ($MACresult
                                                && (unpack('H*', $MACresult->{
                                                        "$oid_lldpRemPortId.$cache_lldpRemTimeMark.$cache_lldpRemLocalPortNum.$cache_lldpRemIndex"
                                                        })
                                                =~ /^([0-9A-Z]{2})([0-9A-Z]{2})([0-9A-Z]{2})([0-9A-Z]{2})([0-9A-Z]{2})([0-9A-Z]{2})/i
                                                )
                                                )
                                        {
                                                push @phones, lc("$1:$2:$3:$4:$5:$6");
                                        }
                                }
                        }
                }
        }
        return @phones;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
