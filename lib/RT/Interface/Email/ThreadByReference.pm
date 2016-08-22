package RT::Interface::Email::ThreadByReference;

use strict;
use warnings;

use RT::Interface::Email ();

sub GetCurrentUser {
    $RT::Logger->debug("Entering ThreadByReference");

    my %args = (
	Message       => undef,
	RawMessageRef => undef,
	CurrentUser   => undef,
	AuthLevel     => undef,
	Action        => undef,
	Ticket        => undef,
	Queue         => undef,
	@_
	);

    if ($args{'Ticket'}->id) {
	$RT::Logger->debug(sprintf("Ticket %s already assigned.  You don't need my help!", 
			   $args{'Ticket'}->id));
	return ($args{'CurrentUser'}, $args{'AuthLevel'});
    }

    $RT::Logger->debug(sprintf("Operating on queue %s", $args{'Queue'}));

    my @messageids = FetchPossibleHeaders($args{'Message'});

    unless (scalar @messageids >= 1) {
	$RT::Logger->debug("Message contains no headers!");
	return ($args{'CurrentUser'}, $args{'AuthLevel'});
    }

    my %tickets = ();
    foreach my $messageid (@messageids) {
	if (my $ids = MessageIdToTicket($messageid)) {
	    foreach my $ticket ($ids) {
		$tickets{$ticket} = undef;
	    }
	}
    }
    
    my @tickets = sort(keys(%tickets));

    if (scalar(@tickets) == 0) {
	$RT::Logger->debug("No tickets for references found.");
	return ($args{'CurrentUser'}, $args{'AuthLevel'});
    }
    elsif (scalar(@tickets) > 1) {
	$RT::Logger->warning("Email maps to more than one ticket.");
	$RT::Logger->warning(sprintf("Tickets: %s", @tickets));
    }

    # We have the ticket.  Set it.
    $RT::Logger->debug(sprintf("Threading email in ticket %s", $tickets[0]));
    $args{'Ticket'}->Load($tickets[0]);

    return ($args{'CurrentUser'}, $args{'AuthLevel'});
}

sub FetchPossibleHeaders {
    my $message = shift();
    
    # The message is a MIME::Entity
    my $head = $message->head();

    my @msgids = ();

    # There may be multiple references
    # In practice, In-Reply-To seems to no longer be worth parsing, as
    # it seems to usually just be a repeat of the References.
    if (my $refs = $head->get('References')) {
	chomp();

	foreach my $ref (split(/\s+/, $refs)) {
	    $ref =~ /,?<([^>]+)>/;
	    if ($1) {
		push(@msgids, $1);
		$RT::Logger->debug(sprintf("Found reference: %s", $1));
	    }
	    else {
		$RT::Logger->debug(sprintf("Reference with borked syntax: %s", $ref));
		next;
	    }
	}
    }
    return @msgids;
}

sub MessageIdToTicket {
    # Copied heavily from rt-references
    my $id = shift();

    my $attachments = RT::Attachments->new($RT::SystemUser);
    $attachments->Limit(
	FIELD => 'MessageId',
	OPERATOR => '=',
	VALUE => $id
	);
    $attachments->Limit(
	FIELD => 'Parent',
	OPERATOR => '=',
	VALUE => '0'
	);

    # Link attachments to their transactions, then transactions to
    # their tickets.
    my $trans = $attachments->NewAlias('Transactions');
    my $tkts = $attachments->NewAlias('Tickets');
    
    $attachments->Join(
	ALIAS1 => 'main',
	FIELD1 => 'TransactionId',
	ALIAS2 => $trans,
	FIELD2 => 'id'
	);
    $attachments->Join(
	ALIAS1 => $trans,
	FIELD1 => 'ObjectID',
	ALIAS2 => $tkts,
	FIELD2 => 'id'
	);
    $attachments->Limit(
	ALIAS => $trans,
	FIELD => 'objecttype',
	OPERATOR => '=',
	VALUE => 'RT::Ticket'
	);

    my %tickets;
    while (my $attach = $attachments->Next) {
	$tickets{$attach->TransactionObj()->Ticket} = undef;
    }

    return keys(%tickets);
}

1;
