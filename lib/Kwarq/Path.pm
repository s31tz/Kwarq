# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Path - Dateisystem-Operationen

=head1 BASE CLASS

L<Kwarq::Object>

=head1 DESCRIPTION

Die Klasse implementiert Operationen auf Dateisystem-Pfaden, sowohl für
Dateien als auch für Verzeichnisse.

=cut

# -----------------------------------------------------------------------------

package Kwarq::Path;
use base qw/Kwarq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use File::Slurp ();
use Kwarq::Shell;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $p = $class->new;

=head4 Returns

Path-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück. Da die Klasse ausschließlich Klassenmethoden
enthält, hat das Objekt die Funktion, eine abkürzende
Aufrufschreibweise zu ermöglichen.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    return bless \(my $dummy),$class;
}

# -----------------------------------------------------------------------------

=head2 Datei-Operationen

=head3 read() - Lies Datei

=head4 Synopsis

  $data = $this->read($file);

=head4 Description

Lies den Inhalt der Datei $file und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub read {
    my $this = shift;
    my $file = $this->expandTilde(shift);

    return File::Slurp::read_file($file);
}

# -----------------------------------------------------------------------------

=head3 write() - Schreibe Datei

=head4 Synopsis

  $this->write($file); # leere Datei
  $this->write($file,$data);
  $this->write($file,\$data);

=head4 Description

Schreibe die Daten $data auf Datei $file.

=cut

# -----------------------------------------------------------------------------

sub write {
    my $this = shift;
    my $file = $this->expandTilde(shift);
    my $data = shift // '';

    my $ref = ref $data? $data: \$data;
    File::Slurp::write_file($file,$$ref);

    return;
}

# -----------------------------------------------------------------------------

=head2 Verzeichnis-Operationen

=head3 mkdir() - Erzeuge Verzeichnis

=head4 Synopsis

  $this->mkdir($dir);

=head4 Description

Erzeuge Verzeichnis $dir. Existiert das Verzeichnis bereits oder ist
$dir leer, ist der Aufruf eine Nulloperation.

=cut

# -----------------------------------------------------------------------------

sub mkdir {
    my $this = shift;
    my $dir = $this->expandTilde(shift);

    return if !defined($dir) || $dir eq '' || -d $dir;

    CORE::mkdir($dir) || do {
        $this->throw(
            'PATH-00001: Can\'t create directory',
            Path => $dir,
        );
    };

    return;
}

# -----------------------------------------------------------------------------

=head2 Pfad-Operationen

=head3 delete() - Lösche Pfad

=head4 Synopsis

  $this->delete($path);

=head4 Description

Lösche den Pfad aus dem Dateisystem, also die Datei oder das Verzeichnis
einschließlich Inhalt. Es ist kein Fehler, wenn der Pfad nicht existiert.

=cut

# -----------------------------------------------------------------------------

sub delete {
    my $this = shift;
    my $path = $this->expandTilde(shift);

    if (!defined($path) || $path eq '' || !-e $path && !-l $path) {
        # Bei Nichtexistenz nichts tun, aber nur, wenn es
        # kein Symlink ist. Bei Symlinks schlägt -e fehl, wenn
        # das Ziel nicht existiert!
    }
    elsif (-d $path) {
        # Verzeichnis löschen
        (my $dir = $path) =~ s/'/\\'/g; # ' quoten
        eval {Kwarq::Shell->exec("/bin/rm -r '$dir' >/dev/null 2>&1")};
        if ($@) {
            $this->throw(
                'PATH-00001: Can\'t delete directory',
                Error => $@,
                Path => $path,
            );
        }
    }
    else {
        # Datei löschen
        if (!CORE::unlink $path) {
            $this->throw(
                'PATH-00001: Can\'t delete file',
                Path => $path,
            );
        }
    }

    return;
}

# -----------------------------------------------------------------------------

=head3 expandTilde() - Expandiere Tilde

=head4 Synopsis

  $path = $this->expandTilde($path);

=head4 Returns

Pfad (String)

=head4 Description

Ersetze eine Tilde am Pfadanfang durch das Home-Verzeichnis des
Benutzers und liefere den resultierenden Pfad zurück.

=cut

# -----------------------------------------------------------------------------

sub expandTilde {
    my ($this,$path) = @_;

    # Unter einem Daemon ist $HOME typischerweise nicht gesetzt, daher
    # prüfen wir zunächst, ob wir $HOME überhaupt expandieren müssen

    if ($path && substr($path,0,1) eq '~') {
        if (!exists $ENV{'HOME'}) {
            $this->throw(
                'PATH-00001: Environment variable HOME does not exist',
            );
        }
        substr($path,0,1) = $ENV{'HOME'};
    }
    
    return $path;
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
