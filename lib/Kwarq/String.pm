# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::String - String-Operationen

=head1 REVISION

$Id: $

=head1 BASE CLASS

L<Kwarq::Object>

=head1 DESCRIPTION

Diese Klasse enthält Methoden zur Manipulation von Strings.

=cut

# -----------------------------------------------------------------------------

package Kwarq::String;
use base qw/Kwarq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Klassenmethoden

=head3 replace() - Ersetze Platzhalter

=head4 Synopsis

  $strOut = $this->replace($strIn,@keyVal);

=head4 Arguments

=over 4

=item $strIn

Zeichenkette mit Platzhaltern

=item @keyVal

Platzhalter/Wert-Paare

=back

=head4 Returns

String

=head4 Description

Ersetze in $strIn Platzhalter durch Werte und liefere das Resultat
zurück. Platzhalter und Werte werden als Paare @keyVal übergeben.

Für jeden Platzhalter mit einem Wert ungleich C<undef> wird geprüft,
ob dieser im Template vorkommt. Wenn nicht, wird eine
Exception geworfen.

=cut

# -----------------------------------------------------------------------------

sub replace {
    my ($this,$str) = splice @_,0,2;
    # @_: @keyVal

    while (@_) {
        my $key = shift;
        my $val = shift;

        if (!defined $val) {
            # Wenn Wert undef, keine Ersetzung. Die Existenz
            # des Platzhalters wird nicht geprüft.
            next;
        }
        
        # wir entfernen Newlines am Ende des Werts
        $val =~ s/\n+$//;
        
        my $exists = 0; # Zeigt an, ob Platzhalter im String vorkommt

        if ($val =~ tr/\n//) {
            # Ist der Wert mehrzeilig, gehen wir jede einzelne Fundstelle
            # durch und rücken jede Zeile des Werts so weit ein wie
            # den Platzhalter

            while (1) {
                if ($str !~ /^([ \t]*).*\Q$key/m) {
                    # Ende: Key kommt nicht mehr vor
                    last;
                }
                $exists++;

                # Wert einrücken

                my $indVal = $val;
                if ($1) {
                    my $ind = $1;
                    $indVal =~ s/^/$ind/mg;
                    $indVal =~ s/^$ind//; # Einr. d. ersten Zeile entfernen
                }

                # Platzhalter durch eingerückten Wert ersetzen
                $str =~ s/\Q$key/$indVal/;
            }
        }
        else {
            # Der Wert ist einzeilig. Wir ersetzen den Platzhalter
            # global, egal wo er steht.

            if ($val eq '') {
                # Steht der Platzhalter allein auf einer Zeile mit
                # Leerzeilen davor und dahinter, entfernen wir zusätzlich
                # zum Platzghalter alle folgenden Leerzeilen

                $exists += $str =~ s/(\n{2,})\Q$key\E\n{2,}/$1/mg;
            }

            # Nicht alleinstehende Platzhalter
            $exists += $str =~ s/\Q$key/$val/g;
        }

        # Exception, wenn Platzhalter mit gesetztem Wert nicht existiert

        if (!$exists) {
            die "ERROR: Placeholder does not exist: $key"; 
        }
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head3 unindent() - Entferne Einrückung und umgebenden Whitespace

=head4 Synopsis

  $strOut = $this->unindent($strIn);

=head4 Arguments

=over 4

=item $strIn

String mit Einrückung oder umgebendem Whitespace.

=back

=head4 Returns

String

=head4 Description

Entferne "unerwünschten" Whitespace von $strIn und liefere das
Ergebnis zurück. Im Einzelnen finden folgende Manipulationen statt:

=over 2

=item *

alle Leerzeilen am Anfang werden entfernt

=item *

jeglicher Whitespace am Ende wird entfernt

=item *

eine Einrückung wird entfernt

=back

=head4 Example

Quelltext

  |    $text = $class->unindent("
  |
  |        SELECT
  |            *
  |        FROM
  |            person
  |        WHERE
  |            nachname = 'Schulz'
  |
  |    ");

ergibt ausgeführt als Wert für $text

  |SELECT
  |    *
  |FROM
  |    person
  |WHERE
  |    nachname = 'Schulz'
                          ^
                          kein Newline

=cut

# -----------------------------------------------------------------------------

sub unindent {
    my $this = shift;
    my $str = shift // return undef;

    $str =~ s/^\s*\n//; # Whitespace bis zur ersten nichtleeren Zeile entf.
    $str =~ s/\s+$//;   # Whitespace am Ende entfernen

    # Wir brauchen uns mit dem String nur dann weiter befassen, wenn das
    # erste Zeichen ein Whitespacezeichen ist. Wenn dies nicht der Fall
    # ist, existiert keine Einrückung, die wir entfernen müssten.

    if ($str =~ /^\s/) {
        my $ind;
        while ($str =~ /^([ \t]*)(.?)/gm) {
            if (length $2 == 0) {
                # Leerzeilen und Whitespace-Zeilen übergehen wir
            }
            elsif (!defined $ind || length $1 < length $ind) {
                $ind = $1;
                if (!$ind) {
                    # Zeile ohne Einrückung gefunden
                    last;
                }
            }
        }
        if ($ind) {
            # gemeinsame Einrückung von allen Zeilen entfernen
            $str =~ s/^$ind//gm;
        }
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head3 unindentReplace() - Entferne Einrückung und ersetze Platzhalter

=head4 Synopsis

  $strOut = $this->unindentReplace($strIn,@keyVal);

=head4 Arguments

=over 4

=item $strIn

String mit Einrückung und Platzhaltern.

=back

=head4 Returns

String

=head4 Description

Entferne von $strIn die Einrückung, ersetze die darin enthaltenen
Platzhalter und liefere das Ergebnis zurück. Die Methode ist die
aufeinanderfolgende Anwendung unindent() und replace().

=cut

# -----------------------------------------------------------------------------

sub unindentReplace {
    my ($this,$str) = splice @_,0,2;
    # @_: @keyVal

    return $this->replace($this->unindent($str),@_);
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
