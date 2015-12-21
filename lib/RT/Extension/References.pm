use strict;
use warnings;

package RT::Extension::References;

our $VERSION = "0.1";

=head1 NAME

RT::Extension::References - Use References to try and find a matching ticket

=head1 DESCRIPTION

RT extension to use the References MIME header in inbound emails to try and
match the message to a preexisting ticket.

=cut

1;

=head1 AUTHOR

Harlan Lieberman-Berg C<< <hlieberm@akamai.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2015, Akamai Technologies, Inc.  All rights reserved.

=cut
