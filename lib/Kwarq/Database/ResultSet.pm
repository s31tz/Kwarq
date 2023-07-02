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

  $tab = $class->new(\@titles,\@rows,$stmt,$duration);

=head4 Returns

Ergebnismenge (Objekt)

=head4 Description

Instantiiere ein Ergebnismengen-Objekt und liefere eine Referenz
auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$titleA,$rowA,$stmt,$duration) = @_;

    return $class->SUPER::new(
        titleA => $titleA,
        rowA => $rowA,
        stmt => $stmt,
        duration => $duration,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 columnWidth() - Länge des längsten Werts einer Kolumne

=head4 Synopsis

  $len = $tab->columnWidth($title);

=head4 Returns

(Integer) Länge

=head4 Description

Liefere die Länge des längsten Werts der Kolumne $title.

=cut

# -----------------------------------------------------------------------------

sub columnWidth {
    my ($self,$title) = @_;

    my $maxLen = 0;
    for my $row (@{$self->{'rowA'}}) {
        my $len = length $row->{$title};
        if ($len > $maxLen) {
            $maxLen = $len;
        }
    }

    return $maxLen;
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

=head3 stmt() - SQL-Statement

=head4 Synopsis

  $stmt = $tab->stmt;

=head4 Returns

(String) SQL-Statement

=head4 Description

Liefere das SQL-Statement, das die Ergebnismenge selektiert hat.

=cut

# -----------------------------------------------------------------------------

# Kein Code, da automatisch erzeugte Attributmethode

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

=head3 asCsv() - Ergebnismenge im CSV-Format

=head4 Synopsis

  $str = $tab->asCsv;
  $str = $tab->asCsv($colSep);

=head4 Arguments

=over 4

=item $colSep (Default: ';')

(String) Kolumnenseparator

=back

=head4 Returns

(String) CSV-Repräsentation

=head4 Description

Wandele die Ergebnismenge ins CSV-Format mit $colSep als
Kolumnenseparator und liefere das Resultat zurück.
Es werden nur die Daten geliefert ohne Titelzeile.

=head4 Example

print $fh join(';',map {uc} $tab->titles)."\n"
print $fh $tab->asCsv(';');

=cut

# -----------------------------------------------------------------------------

sub asCsv {
    my $self = shift;
    my $colSep = shift // ';';

    my $str = '';

    my @titles = $self->titles;
    for my $row ($self->rows) {
        my $i = 0;
        for my $title (@titles) {
            if ($i++) {
               $str .= ';';
            }
            $str .= $row->{$title};
        }
        $str .= "\n";
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head1 VERSION

0.001

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2023 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
