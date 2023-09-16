# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Program - Operationen im Zusammenhang mit dem laufenden Programm

=head1 REVISION

$Id: $

=head1 BASE CLASS

L<Kwarq::Object>

=cut

# -----------------------------------------------------------------------------

package Kwarq::Program;
use base qw/Kwarq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Kwarq::Path;
use File::Temp ();
use Encode ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Klassenmethoden

=head3 help() - Gib die POD-Doku des Programms aus

=head4 Synopsis

  $exitCode = $this->help;
  $exitCode = $this->help($exitCode);
  $exitCode = $this->help($exitCode,$msg);
  $exitCode = $this->help($exitCode,$msg,$callback);

=head4 Description

Gib die POD-Doku des Programms aus, ggf. ergänzt um die Meldung $msg
und liefere den Exitcode, mit dem das Programm terminieren soll
(dafür muss der Aufrufer sorgen) zurück.

=over 2

=item *

Ist $exitCode == 0, wird der Hilfetext auf STDOUT ausgegeben.
Ist $exitCode != 0, wird der Hilfetext auf STDERR ausgegeben.

=item *

Ist $msg angegeben, wird die Hilfeseite oben und unten um Text $msg
ergänzt (jeweils mit einer Leerzeile abgetrennt).

=item *

Ist $exitCode == 0 und STDOUT mit einem Terminal verbunden, wird
der Hilfetext im Pager (less) dargestellt.

=back

=cut

# -----------------------------------------------------------------------------

sub help {
    my $this = shift;
    my $exitCode = shift // 0;
    my $msg = shift // '';
    my $callback = shift;

    # Encoding des POD-Dokuments ermitteln

    my $code = Kwarq::Path->read($0);
    my $podEncoding = 'UTF-8';
    if ($code =~ /^=encoding\s+(\S+)/m) {
        $podEncoding = $1;
    }

    if ($callback) {
        $code = $callback->($code);
    }
    my $fhTmp = File::Temp->new;
    my $tmpFile = $fhTmp->filename;

    open my $fh,'>',$tmpFile or $this->throw(
        'PROGRAM-00099: Open for writing failed',
        File => $tmpFile,
    );
    binmode $fh,':encoding(UTF-8)';
    print $fh $code;
    close $fh;

    # Doku erzeugen und dekodieren

    # my $text = -t STDOUT? qx/pod2text --overstrike $0/: qx/pod2text $0/;
    my $text = -t STDOUT? qx/pod2text --overstrike $tmpFile/:
        qx/pod2text $tmpFile/;
    $text = Encode::decode($podEncoding,$text);
    $text =~ s/\n+$/\n/;

    if ($msg) {
        $msg =~ s/\n+$//;
        $text =~ s/\n+$//;
        $text = "$msg\n-----\n$text\n-----\n$msg\n";
    }

    # Doku anzeigen

    if ($exitCode) {
        # Ausgabe auf STDERR
        print STDERR $text;
    }
    elsif (-t STDOUT) {
        # Anzeige im Pager

        my $cmd = 'LESSCHARSET=UTF-8 less -i';
        open my $fh,'|-',$cmd or $this->throw(
            'PROGRAM-00099: Open of command failed',
            Command => $cmd,
        );
        binmode $fh,':encoding(UTF-8)';
        print $fh $text;
        close $fh;
    }
    else {
        # Ausgabe auf STDOUT
        print $text;
    }

    return $exitCode;
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
