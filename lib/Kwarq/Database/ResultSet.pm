# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Database::ResultSet - Ergebnismenge

=head1 REVISION

$Id: $

=head1 BASE CLASS

L<Kwarq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert eine Ergebnismenge, bestehend
aus allen Datensätzen einer Selektion zusammen mit den Kolumnentiteln.

=cut

# -----------------------------------------------------------------------------

package Kwarq::Database::ResultSet;
use base qw/Kwarq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $tab = $class->new(\@titles,\@rows);

=head4 Returns

Ergebnismenge (Objekt)

=head4 Description

Instantiiere ein Ergebnismengen-Objekt und liefere eine Referenz
auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$titleA,$rowA) = @_;

    return $class->SUPER::new(
        titleA => $titleA,
        rowA => $rowA,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 rows() - Liste der Datensätze

=head4 Synopsis

  @rows | $rowA = $tab->rows;

=head4 Returns

(Array of Rows) Liste von Datensätzen. Im Skalarkontext eine Referenz
auf die Liste.

=head4 Description

Liefere die Liste der Datensätze der Ergebnismenge.

=cut

# -----------------------------------------------------------------------------

sub rows {
    my $self = shift;
    return wantarray? @{$self->{'rowA'}}: $self->{'rowA'};
}

# -----------------------------------------------------------------------------

=head3 count() - Anzahl der Datensätze

=head4 Synopsis

  $n = $tab->count;

=head4 Returns

(Integer) Anzahl Datensätze.

=head4 Description

Liefere die Anzahl der Datensätze der Ergebnismenge.

=cut

# -----------------------------------------------------------------------------

sub count {
    my $self = shift;
    return scalar @{$self->{'rowA'}};
}

# -----------------------------------------------------------------------------

=head3 titles() - Liste der Kolumnentitel

=head4 Synopsis

  @titles | $titleA = $tab->titles;

=head4 Returns

(Array of Strings) Liste von Kolumnentiteln. Im Skalarkontext eine Referenz
auf die Liste.

=head4 Description

Liefere die Liste der Kolumnentitel der Ergebnismenge.

=cut

# -----------------------------------------------------------------------------

sub titles {
    my $self = shift;
    return wantarray? @{$self->{'titleA'}}: $self->{'titleA'};
}

# -----------------------------------------------------------------------------

=head1 VERSION

0.001

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2022 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
