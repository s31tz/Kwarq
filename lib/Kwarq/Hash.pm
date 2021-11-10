package Kwarq::Hash;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Hash::Util ();

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Hash - Hash mit geschützten Keys

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert einen Hash, dessen Schlüssel
geschützt sind.

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $h = $class->new(@keyVal);
  $h = $class->new($h);

=head4 Arguments

=over 4

=item @keyVal

Liste von Schlüssel/Wert-Paaren.

=item $h

Hash-Referenz

=back

=head4 Returns

Hash-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal -or- $h

    my $self;
    if (@_ == 1) {
        $self = bless $_[0],$class;
    }
    else {
        $self = bless {@_},$class;
    }
    Hash::Util::lock_keys(%$self);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 get() - Liefere Wert

=head4 Synopsis

  $val = $class->get($key);

=head4 Returns

Wert (String)

=head4 Description

Ermittele den Wert der Hash-Komponente $key und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub get {
    my ($self,$key) = @_;
    return $self->{$key};
}

# -----------------------------------------------------------------------------

=head1 VERSION

0.001

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2021 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
