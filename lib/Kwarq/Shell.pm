# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Shell - Führe Shell-Kommando aus

=head1 BASE CLASS

L<Kwarq::Hash>

=cut

# -----------------------------------------------------------------------------

package Kwarq::Shell;
use base qw/Kwarq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Kwarq::Path;
use File::Temp ();
use Cwd ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $sh = $class->new;

=head4 Returns

Object

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    return $class->SUPER::new(
        dirStack => [],
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 exec() - Führe Kommando aus

=head4 Synopsis

  $stdout = $this->exec($cmd);
  ($stdout,$stderr) = $this->exec($cmd);

=head4 Arguments

=over 4

=item $cmd

Das auszuführende Shell-Kommando.

=back

=head4 Returns

=over 4

=item $stdout

Die Ausgabe des Kommandos auf STDOUT.

=item $stderr

Die Ausgabe des Kommandos auf STDERR.

=back

=head4 Description

Führe Kommando $cmd aus und liefere die Ausgabe auf STDOUT und STDERR
zurück. Im Fehlerfall wird eine Exception geworfen.

=cut

# -----------------------------------------------------------------------------

sub exec {
    my ($this,$cmd) = @_;

    my $fh1 = File::Temp->new;
    my $stdoutFile = $fh1->filename;
    my $fh2 = File::Temp->new;
    my $stderrFile = $fh2->filename;

    system "($cmd) 1>$stdoutFile 2>$stderrFile";
    $this->check($?,$cmd);

    my $p = Kwarq::Path->new;

    my $stdout = $p->read($stdoutFile);
    if (wantarray) {
        my $stderr = $p->read($stderrFile);
        return ($stdout,$stderr);
    }

    return $stdout;
}

# -----------------------------------------------------------------------------

=head3 cd() - Wechsele Arbeitsverzeichnis

=head4 Synopsis

  $sh->cd($dir);

=head4 Arguments

=over 4

=item $dir

Verzeichnis, in das gewechselt werden soll.

=back

=head4 Description

Wechsle in Arbeitsverzeichnis $dir. Im Fehlerfall wird eine Exception
geworfen. Intern hält das Objekt einen Stack, auf dem die
Verzeichniswechsel gespeichert sind. Mit $sh->back kann in das vorherige
Verzeichnis zurückgewechselt werden.

=cut

# -----------------------------------------------------------------------------

sub cd {
    my $self = shift;
    my $dir = Kwarq::Path->expandTilde(shift);

    my $cwd = Cwd::cwd;
    CORE::chdir $dir or do {
        $self->throw(
            'SHELL-00001: Cannot change directory',
            Directory => $dir,
            CurrentWorkingDirectory => $cwd,
        );
    };
    push @{$self->{'dirStack'}},$cwd;

    return;
}

# -----------------------------------------------------------------------------

=head3 back() - Wechsele ins vorige Arbeitsverzeichnis zurück

=head4 Synopsis

  $sh->back;

=head4 Description

Wechsele in das Verzeichnis zurück, aus dem heraus zuvor mit $sh->cd()
in das aktuelle Verzeichnis gewechselt wurde. Gab es zuvor keinen
Verzeichniswechsel, ist es eine Nulloperation.

=cut

# -----------------------------------------------------------------------------

sub back {
    my $self = shift;

    my $dir = pop @{$self->{'dirStack'}};
    unless ($dir) {
        return;
    }

    CORE::chdir $dir or do {
        $self->throw(
            'SHELL-00001: Cannot change directory',
            Directory => $dir,
            CurrentWorkingDirectory => Cwd::cwd,
        );
    };

    return;
}

# -----------------------------------------------------------------------------

=head2 Klassenmethoden

=head3 check() - Prüfe Status eines terminierten Child-Prozesses

=head4 Synopsis

  $this->check;
  $this->check($exitCode);
  $this->check($exitCode,$cmd);

=head4 Arguments

=over 4

=item $exitCode (Default: $?)

(Integer) Der Returnwert von system() oder $? im Falle von qx// (bzw. ``).

=item $cmd (Default: undef)

(String) Ausgeführtes Kommando. Dieses wird im Fehlerfall
in den Exception-Text eingesetzt.

=back

=head4 Description

Prüfe den Status eines terminierten Child-Prozesses und löse
eine Execption aus, wenn dieser ungleich 0 ist.

=head4 Examples

Prüfe den Status nach Aufruf von system():

  my $r = system($cmd);
  Kwarq::Shell->check($r,$cmd);

Minimale Variante (Prüfung über $?):

  system($cmd);
  Kwarq::Shell->check;

Prüfe den Status nach Anwendung des Backtick-Operators:

  $str = `$cmd`;
  Kwarq::Shell->check($?,$cmd);

=cut

# -----------------------------------------------------------------------------

sub check {
    my $this = shift;
    my $exitCode = shift;
    my $cmd = shift;

    if ($exitCode == 0) {
        return; # ok
    }
    elsif ($exitCode == -1) {
        $this->throw(
            'CMD-00001: Failed to execute command',
            Command => $cmd,
            ErrorMessage => $!,
        );
    }
    elsif ($exitCode & 127) {       # Abbruch mit Signal
        my $sig = $exitCode & 127;  # unterste 8 Bit sind Signalnummer
        my $core = $exitCode & 128; # das 8. Bit zeigt Coredump an
        $this->throw(
            'CMD-00003: Child died with signal',
            Signal => $sig.($core? ' (Coredump)': ''),
            Command => $cmd,
            ErrorMessage => $!,
        );
    }
    $exitCode >>= 8;
    $this->throw(
        'CMD-00002: Command failed with error',
        ExitCode => $exitCode,
        Command => $cmd,
        Cwd => Cwd::getcwd,
        ErrorMessage => $!,
    );
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
