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
use utf8;

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

=head4 Options

=over 4

=item -xml => $bool (Default: 0)

Wandele & < > in den Daten in Entity-Schreibweise. In der Folge
der Schlüssel/Wert-Paare @keyVal kann mittels der Option die
Wandlung an- und -abgeschaltet werden.

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

    # Dynamische Option
    my $xml = 0;

    while (@_) {
        my $key = shift;
        my $val = shift;

        if ($key eq '-xml') {
            $xml = $val;
            next;
        }

        if (!defined $val) {
            # Wenn Wert undef, keine Ersetzung. Die Existenz
            # des Platzhalters wird nicht geprüft.
            next;
        }
        
        # wir entfernen Newlines am Ende des Werts
        $val =~ s/\n+$//;

        if ($xml) {
            # Wir maskieren < > &

            $val =~ s/&/&amp;/g;
            $val =~ s/</&lt;/g;
            $val =~ s/>/&gt;/g;
        }

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

=head3 umlautToAscii() - Wandele deutsche Umlaute und SZ nach ASCII

=head4 Synopsis

  $class->umlautToAscii(\$str);
  $newStr = $class->umlautToAscii($str);

=head4 Description

Schreibe ä, Ä, ö, Ö, ü, Ü, ß in ae, Ae, oe, Oe, ue, Ue, ss um
und liefere das Resultat zurück. Wird eine Stringreferenz angegeben,
findet die Umschreibung "in-place" statt.

Die Methode setzt voraus, dass der String korrekt dekodiert wurde.

=cut

# -----------------------------------------------------------------------------

sub umlautToAscii {
    my ($class,$arg) = @_;

    my $ref = ref $arg? $arg: \$arg;

    if (defined $$ref) {
        $$ref =~ s/ä/ae/g;
        $$ref =~ s/ö/oe/g;
        $$ref =~ s/ü/ue/g;
        $$ref =~ s/Ä/Ae/g;
        $$ref =~ s/Ö/Oe/g;
        $$ref =~ s/Ü/Ue/g;
        $$ref =~ s/ß/ss/g;
    }

    return ref $arg? (): $$ref;
}

# -----------------------------------------------------------------------------

=head3 unindent() - Entferne Einrückung und umgebenden Whitespace

=head4 Synopsis

  $strOut = $this->unindent($strIn);
  $strOut = $this->unindent($strIn,$lineContinuation);

=head4 Arguments

=over 4

=item $strIn

String mit Einrückung oder umgebendem Whitespace.

=item $lineContinuation

Löse einen Backslash am Zeilenende als Zeilenfortsetzungszeichen auf.

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
    my $lineContinuation = shift;

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

    if ($lineContinuation) {
        # Zeilenfortsetzungszeichen auflösen
        $str =~ s|\\\n\s*||g;
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

Copyright (C) 2024 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
