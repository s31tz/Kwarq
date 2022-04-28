# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Object - Basisklasse aller Klassen

=head1 REVISION

$Id: $

=head1 SYNOPSIS

  package MyClass;
  use base qw/Kwarq::Object/;
  ...

=cut

# -----------------------------------------------------------------------------

package Kwarq::Object;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Exceptions

=head3 throw() - Wirf Exception mit Stacktrace und Zusatzinformation

=head4 Synopsis

  $this->throw;
  $this->throw(@opt,@keyVal);
  $this->throw($msg,@opt,@keyVal);

=head4 Arguments

=over 4

=item $msg

Meldung

=item @keyVal

Liste von Schlüssel/Wert-Paaren, die mit der Meldung zusammen erscheinen.
Diese liefern Detail-Informtion zum Fehler.

=back

=head4 Options

=over 4

=item -stdout => $bool (Default: 0)

Wenn -warning => 1 gesetzt ist, erzeuge die Meldung
auf STDOUT statt STDERR.

=item -stacktrace => $bool (Default: 1)

Ergänze den Exception-Text um einen Stacktrace.

=item -warning => $bool (Default: 0)

Wirf keine Exception, sondern gib lediglich eine Warnung aus.

=back

=head4 Description

Wirf eine Exception mit dem Fehlertext $msg, den hinzugefügten
Schlüssel/Wert-Paaren @keyVal und einem Stacktrace. Die Methode kehrt
nicht zurück, außer wenn Option -warning gesetzt ist, dann wird
nur der Exception-Text ausgegeben.

=cut

# -----------------------------------------------------------------------------

sub throw {
    my $class = ref $_[0]? ref(shift): shift;
    # @_: $msg,@keyVal

    # Optionen nicht durch eine andere Klasse verarbeiten!
    # Die Klasse soll auf keiner anderen Klasse basieren.

    my $stdout = 0;
    my $stacktrace = 1;
    my $warning = 0;

    for (my $i = 0; $i < @_; $i++) {
        if (!defined $_[$i]) {
            next;
        }
        elsif ($_[$i] eq '-stdout') {
            $stdout = $_[$i+1];
            splice @_,$i--,2;
        }
        elsif ($_[$i] eq '-stacktrace') {
            $stacktrace = $_[$i+1];
            splice @_,$i--,2;
        }
        elsif ($_[$i] eq '-warning') {
            $warning = $_[$i+1];
            splice @_,$i--,2;
        }
    }

    my $msg = 'Unexpected error';
    if (@_ % 2) {
        $msg = shift;
    }

    # Newlines am Ende entfernen
    $msg =~ s/\n$//;

    # Schlüssel/Wert-Paare

    my $keyVal = '';
    for (my $i = 0; $i < @_; $i += 2) {
        my $key = $_[$i];
        my $val = $_[$i+1];

        # FIXME: überlange Werte berücksichtigen
        if (defined $val) {
            $val =~ s/\s+$//; # Whitespace am Ende entfernen
        }

        if (defined $val && $val ne '') {
            $key = ucfirst $key;
            if ($warning) {
                if ($keyVal) {
                    $keyVal .= ', ';
                }
                $keyVal .= "$key=$val";
            }
            else {
                $val =~ s/^/    /mg; # mehrzeiligen Wert einrücken
                $keyVal .= "$key:\n$val\n";
            }
        }
    }

    if ($warning) {
        # Keine Exception, nur Warnung

        my $msg = "WARNING: $msg. $keyVal\n";
        if ($stdout) {
            print $msg;
        }
        else {
            warn $msg;
        }
        return;
    }

    # Bereits generierte Exception noch einmal werfen
    # (nachdem Schlüssel/Wert-Paare hinzugefügt wurden)

    if ($msg =~ /^Exception:\n/) {
        my $pos = index($msg,'Stacktrace:');
        if ($pos >= 0) {
            # mit Stacktrace
            substr $msg,$pos,0,$keyVal;
        }
        else {
            # ohne Stacktrace
            $msg .= $keyVal;
        }
        $msg =~ s/\n*$/\n/; # Meldung endet mit genau einem NL

        die $msg;
    }

    # Generiere Meldung

    $msg =~ s/^/    /mg;
    my $str = "Exception:\n$msg\n";
    if ($keyVal) {
        $str .= $keyVal;
    }

    if ($stacktrace) {
        # Generiere Stacktrace

        my $stack = '';

        my $i = 0;
        my @frames;
        while (my (undef,$file,$line,$sub) = caller $i++) {
            push @frames,[$file,$line,$sub];
        }

        $i = 0;
        for my $frame (reverse @frames) {
            my ($file,$line,$sub) = @$frame;
            $sub .= "()" if $sub ne '(eval)';
            $stack .= sprintf "%s%s [+%s %s]\n",('  'x$i++),$sub,$line,$file;
        }
        chomp $stack;
        $stack =~ s/^/    /gm;

        $str .= "Stacktrace:\n$stack\n";
    }

    # Wirf Exception
    die $str;
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
