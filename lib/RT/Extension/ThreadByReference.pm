use strict;
use warnings;
package RT::Extension::ThreadByReference;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-ThreadByReference - Use the MIME Reference header to try and thread messages to tickets

=head1 DESCRIPTION

When an RT ticketing queue is CCed on a message thread, it can be very
difficult to get the subject lines correct in all parts of the
message.  This can cause a single thread to spawn off tens of
different tickets that need manual merging.

This extension uses the MIME Reference header to search for threads
to associate a message with.

=head1 RT VERSION

Works with RT 4.0 and greater.

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

If you are using RT 4.2 or greater, add this line:

    Plugin('RT::Extension::ThreadByReference');

For RT 4.0, add this line:

    Set(@Plugins, qw(RT::Extension::ThreadByReference));

or add C<RT::Extension::ThreadByReference> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 AUTHOR

Harlan Lieberman-Berg C<< <hlieberm@akamai.com> >>

=head1 BUGS

All bugs should be reported via email to

    L<bug-RT-Extension-ThreadByReference@rt.cpan.org|mailto:bug-RT-Extension-ThreadByReference@rt.cpan.org>

or via the web at

    L<rt.cpan.org|http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-ThreadByReference>.

=head1 LICENSE

Copyright (c) 2015-2016 by Akamai Technologies, Inc.

This software is free software; you can redistribute and/or modify it
under the same terms as Perl itself.

=cut

1;
