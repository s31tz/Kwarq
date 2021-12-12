# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Database::Row - Datensatz

=head1 REVISION

$Id: $

=head1 BASE CLASS

L<Kwarq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert einen Datensatz.

=cut

# -----------------------------------------------------------------------------

package Kwarq::Database::Row;
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

  $row = $class->new($h);

=head4 Returns

Datensatz (Objekt)

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

# Funktionalität kommt aus der Basisklasse

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
