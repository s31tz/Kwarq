# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Hash - Hash mit geschützten Keys

=head1 BASE CLASS

L<Kwarq::Object>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert einen Hash, dessen Schlüssel
geschützt sind.

=cut

# -----------------------------------------------------------------------------

package Kwarq::Hash;
use base qw/Kwarq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Hash::Util ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $h = $class->new(@keyVal);
  $h = $class->new($h);

=head4 Arguments

=over 4

=item @keyVal

Liste von Schlüssel/Wert-Paaren.

=item $h

Hash-Referenz

=back

=head4 Returns

Hash-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal -or- $h

    my $self;
    if (@_ == 1) {
        $self = bless $_[0],$class;
    }
    else {
        $self = bless {@_},$class;
    }
    Hash::Util::lock_keys(%$self);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 get() - Liefere einen oder mehrere Werte

=head4 Synopsis

  $val = $h->get($key);
  @vals = $h->get(@keys);

=head4 Arguments

=over 4

=item $key

Schlüssel

=item @keys

Liste von Schlüsseln

=back

=head4 Returns

Im Skalarkontext einen Wert (String), im Array-Kontext eine Liste
von Werten (Array of Strings)

=head4 Description

Ermittele den Wert der Hash-Komponente $key oder die Werte der
Hash-Komponenten @keys und liefere diese zurück.

=cut

# -----------------------------------------------------------------------------

sub get {
    my $self = shift;
    # @_: $key -or- @keys

    if (wantarray) {
        my @arr;
        while (@_) {
            my $key = shift;
            push @arr,$self->{$key};
        }
        return @arr;
    }

    return $self->{$_[0]};
}

# -----------------------------------------------------------------------------

=head2 Automatische Akzessor-Methoden

=head3 AUTOLOAD() - Erzeuge Akzessor-Methode

=head4 Synopsis

  $val = $h->AUTOLOAD;
  $val = $h->AUTOLOAD($val);

=head4 Description

Diese Methode erweitert die Klassenhierarchie um automatisch
generierte Akzessor-Methoden. D.h. für jede Komponente des Hash
wird bei Bedarf eine Methode erzeugt, durch die der Wert der
Komponente manipuliert werden kann. Dadurch ist es möglich, das
Abfragen und Setzen von Attributen ohne Programmieraufwand nahtlos
in die Methodenschnittstelle einer Klasse zu integrieren.

Gegenüberstellung:

  Hash-Zugriff           get()/set()               Methoden-Zugriff
  --------------------   -----------------------   --------------------
  $name = $h->{'name'}   $name = $h->get('name')   $name = $h->name
  $h->{'name'} = $name   $h->set(name=>$name)      $h->name($name) -or-
                                                   $h->name = $name

In der Spalte "Methoden-Zugriff" steht die Syntax der
automatisch generierten Akzessor-Methoden.

Die Akzessor-Methode wird als lvalue-Methode generiert, d.h. die
Hash-Komponente kann per Akzessor-Aufruf manipuliert werden. Beispiele:

  $h->name = $name;
  $h->name =~ s/-//g;

Die Erzeugung einer Akzessor-Methode erfolgt (vom Aufrufer unbemerkt)
beim ersten Aufruf. Danach wird die Methode unmittelbar gerufen.

Der Zugriff über eine automatisch generierte Attributmethode ist ca. 30%
schneller als über $h->L<get|"get() - Liefere einen oder mehrere Werte">().

=cut

# -----------------------------------------------------------------------------

sub AUTOLOAD :lvalue {
    my $this = shift;
    # @_: Methodenargumente

    my ($key) = our $AUTOLOAD =~ /::(\w+)$/;
    return if $key !~ /[^A-Z]/;

    # Klassenmethoden generieren wir nicht

    if (!ref $this) {
        $this->throw(
            'HASH-00002: Class method does not exist',
            Method => $key,
        );
    }

    # Methode nur generieren, wenn Attribut existiert

    if (!exists $this->{$key}) {
        $this->throw(
            'HASH-00001: Hash key or object method does not exist',
            Attribute => $key,
            Class => ref($this)? ref($this): $this,
        );
    }

    # Attribut-Methode generieren. Da $self ein Restricted Hash ist,
    # brauchen wir die Existenz des Attributs nicht selbst zu prüfen.

    no strict 'refs';
    *{$AUTOLOAD} = sub :lvalue {
        my $self = shift;
        # @_: $val

        if (@_) {
            $self->{$key} = shift;
        }

        return $self->{$key};
    };

    # Methode aufrufen
    return $this->$key(@_);
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
