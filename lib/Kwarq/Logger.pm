# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Logger - Schreiben von Logmeldungen

=head1 BASE CLASS

L<Kwarq::Hash>

=cut

# -----------------------------------------------------------------------------

package Kwarq::Logger;
use base qw/Kwarq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Kwarq::String;
use Kwarq::Path;
use POSIX ();
use Encode ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $log = $class->new($level,$file,$toTerm);

=head4 Arguments

=over 4

=item $level

(String) Loglevel: Es werden fünf Loglevel unterschieden: 'DEBUG', 'INFO',
'WARN', 'ERROR', 'FATAL'.

=item $file

(Pfad) Die Datei, in die die Meldungen gelogged werden.

=item $toTerm

(Bool) Ob die Meldungen außer in die Logdatei auch auf STDOUT ausgegeben
werden sollen.

=back

=head4 Returns

Logger-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

my $Logger;

my %Level = (
    DEBUG => 1,
    INFO => 2,
    WARN => 3,
    ERROR => 4,
    FATAL => 5,
);
my %LevelReverse = reverse %Level;

sub new {
    my ($class,$level,$file,$toTerm) = @_;

    $| = 1;

    return $Logger = $class->SUPER::new(
        level => $Level{$level},
        file => $file,
        toTerm => $toTerm,
    );
}

# -----------------------------------------------------------------------------

=head3 logger() - Liefere Logger-Objekt

=head4 Synopsis

  $log = $class->logger;

=head4 Returns

Logger-Objekt

=head4 Description

Ermittele das Logger-Objekt und liefere dieses zurück. Das Logger-Objekt
muss zuvor natürlich instantiiert worden sein.

=cut

# -----------------------------------------------------------------------------

sub logger {
    my $class = shift;
    return $Logger // $class->throw(
        'LOGGER-00099: Logger object not instantiated',
    );
}

# -----------------------------------------------------------------------------

=head3 level() - Liefere Level (Bezeichnung)

=head4 Synopsis

  $level = $log->level;

=head4 Returns

(String) Bezeichnung des Loglevel ('DEBUG', ...)

=head4 Description

Liefere die Bezeichnung des Loglevel.

=cut

# -----------------------------------------------------------------------------

sub level {
    my $self = shift;
    return $LevelReverse{$self->{'level'}};
}

# -----------------------------------------------------------------------------

=head2 Logmeldung auf Loglevel schreiben

=head3 debug() - Schreibe DEBUG Logmeldung

=head4 Synopsis

  $log->debug($msg);
  $log->debug($msg,$noIndent);

=head4 Arguments

=over 4

=item $msg

(String) Logmeldung

=item $noIndent (Default: 0)

(Boolean) Keine Einrückung einer mehrzeiligen $msg

=back

=head4 Description

Schreibe die Meldung $msg als DEBUG ins Log und - falls bei der
Instantiierung angegeben - nach STDOUT (Terminal).

=cut

# -----------------------------------------------------------------------------

sub debug {
    my ($self,$msg,$noIndent) = @_;
    $self->write('DEBUG',$msg,$noIndent);
}

# -----------------------------------------------------------------------------

=head3 info() - Schreibe INFO Logmeldung

=head4 Synopsis

  $log->info($msg);
  $log->info($msg,$noIndent);

=head4 Arguments

=over 4

=item $msg

(String) Logmeldung

=item $noIndent (Default: 0)

(Boolean) Keine Einrückung einer mehrzeiligen $msg

=back

=head4 Description

Schreibe die Meldung $msg als INFO ins Log und - falls bei der
Instantiierung angegeben - nach STDOUT (Terminal).

=cut

# -----------------------------------------------------------------------------

sub info {
    my ($self,$msg,$noIndent) = @_;
    $self->write('INFO',$msg,$noIndent);
}

# -----------------------------------------------------------------------------

=head3 warn() - Schreibe WARN Logmeldung

=head4 Synopsis

  $log->warn($msg);
  $log->warn($msg,$noIndent);

=head4 Arguments

=over 4

=item $msg

(String) Logmeldung

=item $noIndent (Default: 0)

(Boolean) Keine Einrückung einer mehrzeiligen $msg

=back

=head4 Description

Schreibe die Meldung $msg als WARN ins Log und - falls bei der
Instantiierung angegeben - nach STDOUT (Terminal).

=cut

# -----------------------------------------------------------------------------

sub warn {
    my ($self,$msg,$noIndent) = @_;
    $self->write('WARN',$msg,$noIndent);
}

# -----------------------------------------------------------------------------

=head3 error() - Schreibe ERROR Logmeldung

=head4 Synopsis

  $log->error($msg);
  $log->error($msg,$noIndent);

=head4 Arguments

=over 4

=item $msg

(String) Logmeldung

=item $noIndent (Default: 0)

(Boolean) Keine Einrückung einer mehrzeiligen $msg

=back

=head4 Description

Schreibe die Meldung $msg als ERROR ins Log und - falls bei der
Instantiierung angegeben - nach STDOUT (Terminal).

=cut

# -----------------------------------------------------------------------------

sub error {
    my ($self,$msg,$noIndent) = @_;
    $self->write('ERROR',$msg,$noIndent);
}

# -----------------------------------------------------------------------------

=head3 fatal() - Schreibe FATAL Logmeldung

=head4 Synopsis

  $log->fatal($msg);
  $log->fatal($msg,$noIndent);

=head4 Arguments

=over 4

=item $msg

(String) Logmeldung

=item $noIndent (Default: 0)

(Boolean) Keine Einrückung einer mehrzeiligen $msg

=back

=head4 Description

Schreibe die Meldung $msg als FATAL ins Log und - falls bei der
Instantiierung angegeben - nach STDOUT (Terminal) B<und terminiere
die Ausführung des Programms>.

=cut

# -----------------------------------------------------------------------------

sub fatal {
    my ($self,$msg,$noIndent) = @_;
    $self->write('FATAL',$msg,$noIndent);
    exit 99;
}

# -----------------------------------------------------------------------------

=head2 Grundlegende Methoden

=head3 write() - Schreibe Logmeldung

=head4 Synopsis

  $log->write($level,$msg,$noIndent);

=head4 Arguments

=over 4

=item $level

(Enum) Level der Logmeldung

=item $msg

(String) Logmeldung

=item $noIndent

(Boolean) Rücke mehrzeilige Meldung nicht ein

=back

=head4 Description

Schreibe die Meldung $msg ins Log und - falls bei der Instantiierung
angegeben - nach STDOUT (Terminal).

=cut

# -----------------------------------------------------------------------------

sub write {
    my ($self,$level,$msg,$noIndent) = @_;

    if ($Level{$level} < $self->{'level'}) {
        return;
    }

    $msg = Kwarq::String->unindent($msg);
    if ($msg =~ /\n/) { # mehrzeilige Meldung
        if (!$noIndent) {
            $msg =~ s/^/| /mg;
        }
        $msg = "\n$msg\n";
    }
    else {
        $msg = " $msg\n";
    }

    $msg = sprintf '%s %6d %-5s%s',
        POSIX::strftime('%Y-%m-%d %H:%M:%S',localtime),$$,$level,$msg;

    if ($self->{'toTerm'}) {
        print $msg;
    }

    Kwarq::Path->append($self->{'file'},
        Encode::encode('utf-8',$msg));

    return;
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
