# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Hash - Hash mit geschützten Keys

=head1 REVISION

$Id: $

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

use Scalar::Util ();
use Hash::Util ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $h = $class->new(\@keys);
  $h = $class->new(\@keys,$default);
  $h = $class->new(\@keys,\@vals);
  $h = $class->new($h);
  $h = $class->new(@keyVal);

=head4 Arguments

=over 4

=item @keys

Liste an Schlüsseln

=item $default

Defaultwert für alle Keys

=item @keyVal

Liste von Schlüssel/Wert-Paaren

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
    my $refType = Scalar::Util::reftype($_[0]);
    if ($refType && $refType eq 'ARRAY') {
        $self = bless {},$class;
        my $refType = Scalar::Util::reftype($_[1]);
        if ($refType && $refType eq 'ARRAY') { # \@keys,\@vals
            my $i = 0;
            for (@{$_[0]}) {
                $self->{$_} = $_[1]->[$i++];
            }
        }
        else { # \@keys,$default
            for (@{$_[0]}) {
                $self->{$_} = $_[1];
            }
        }
    }
    elsif (@_ == 1) { # $h
        $self = bless $_[0],$class;
    }
    else { # @keyVal
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

=head3 set() - Setze Schlüssel/Wert-Paare

=head4 Synopsis

  $h->set(@keyVal);

=head4 Description

Setze die angegebenen Schlüssel/Wert-Paare.

Alternative Formulierung:

  $h->{$key} = $val;    # ein Schlüssel/Wert-Paar
  @{$h}{@keys} = @vals; # mehrere Schlüssel/Wert-Paare

=cut

# -----------------------------------------------------------------------------

sub set {
    my $self = shift;
    # @_: @keyVal

    while (@_) {
        my $key = shift;
        $self->{$key} = shift;
    }

    return;
}

# -----------------------------------------------------------------------------

=head3 add() - Füge Schlüssel/Wert-Paare hinzu

=head4 Synopsis

  $h->add(@keyVal);

=head4 Description

Füge die angegebenen Schlüssel/Wert-Paare zum Hash hinzu.

Alternative Formulierung:

  Hash::Util::unlock_keys(%$h);
  $h->{$key} = $val;    # ein Schlüssel/Wert-Paar
  @{$h}{@keys} = @vals; # mehrere Schlüssel/Wert-Paare
  Hash::Util::lock_keys(%$h);

=cut

# -----------------------------------------------------------------------------

sub add {
    my $self = shift;
    # @_: @keyVal

    $self->unlockKeys;
    $self->set(@_);
    $self->lockKeys;

    return;
}

# -----------------------------------------------------------------------------

=head3 lockKeys() - Sperre Hash

=head4 Synopsis

  $h = $h->lockKeys;

=head4 Description

Sperre den Hash. Anschließend kann kein weiterer Schlüssel zugegriffen
werden. Wird dies versucht, wird eine Exception geworfen.

Alternative Formulierung:

  Hash::Util::lock_keys(%$h);

Die Methode liefert eine Referenz auf den Hash zurück.

=cut

# -----------------------------------------------------------------------------

sub lockKeys {
    my $self = shift;
    Hash::Util::lock_keys(%$self);
    return $self;
}

# -----------------------------------------------------------------------------

=head3 unlockKeys() - Entsperre Hash

=head4 Synopsis

  $h = $h->unlockKeys;

=head4 Description

Entsperre den Hash. Anschließend kann der Hash uneingeschränkt
manipuliert werden. Die Methode liefert eine Referenz auf den Hash
zurück. Damit kann der Hash gleich nach der Instantiierung
entsperrt werden:

  return Kwarq::Hash->new(...)->unlockKeys;

Alternative Formulierung:

  Hash::Util::unlock_keys(%$h);

=cut

# -----------------------------------------------------------------------------

sub unlockKeys {
    my $self = shift;
    Hash::Util::unlock_keys(%$self);
    return $self;
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

Copyright (C) 2023 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
