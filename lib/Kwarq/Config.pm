# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Config - Konfigurationsdatei in "Perl Object Notation"

=head1 REVISION

$Id: $

=head1 BASE CLASS

L<Kwarq::Object>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert eine Menge von Attribut/Wert-Paaren,
die in einer Datei mit "Perl Object Notation" definiert sind.

Beispiel für den Inhalt einer Konfigurationsdatei:

  host => 'localhost',
  datenbank => 'entw1',
  benutzer => ['sys','system']

=cut

# -----------------------------------------------------------------------------

package Kwarq::Config;
use base qw/Kwarq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Kwarq::Object;
use Cwd ();
use Scalar::Util ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Konfigurationsobjekt

=head4 Synopsis

  $cfg = $class->new($file);

=head4 Description

Instantiiere ein Konfigurationsobjekt aus der Dateien $file
und liefere eine Referenz auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$file) = @_;
    
    my @arr = CORE::do($file);
    if ($@) {
        Kwarq::Object->throw(
            'CONFIG-00001: do() could not parse file',
            File => $file,
            Cwd => Cwd::getcwd,
            InternalError => $@,
        );
    }
    elsif (@arr == 1 && !defined $arr[0]) {
        Kwarq::Object->throw(
            'PERL-00002: do() could not load file',
            File => $file,
            Cwd => Cwd::getcwd,
            Error => $!,
        );
    }

    my %cfg = @arr;

    return bless \%cfg,$class;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 get() - Liefere einen Wert

=head4 Synopsis

  $val = $cfg->get(@keys);

=head4 Arguments

=over 4

=item @keys

Liste von Schlüsseln, die den Zugriffspfad zum Wert beschreiben.

=back

=head4 Returns

(Skalar) Wert

=head4 Description

Ermittele den Wert der Komponente mit dem Zugriffspfad @keys. Existiert
einer der Schlüssel nicht, liefere C<undef>.

=cut

# -----------------------------------------------------------------------------

sub get {
    my $self = shift;
    # @_: @keys

    my @keys;
    my $ref = $self;
    while (my $key = shift) {
        push @keys,$key;
        if (Scalar::Util::reftype($ref) ne 'HASH' ||
                !exists($ref->{$key})) {
            $self->throw(
                'CONFIG-00099: Path does not exist',
                Path => join('.',@keys),
            );
        }
        $ref = $ref->{$key};
    }

    return $ref;
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
