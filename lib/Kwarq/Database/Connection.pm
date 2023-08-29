# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Kwarq::Database::Connection - Datenbank-Verbindung

=head1 REVISION

$Id: $

=head1 BASE CLASS

L<Kwarq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert eine Datenbankverbindung
über die DBI-Schnittstelle.

=cut

# -----------------------------------------------------------------------------

package Kwarq::Database::Connection;
use base qw/Kwarq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.001';

use Kwarq::String;
use Encode ();
use Kwarq::Database::Row;
use Kwarq::Database::ResultSet;
use Time::HiRes ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $db = $class->new($dbh);
  $db = $class->new($dbh,$encoding);
  $db = $class->new($dbh,$encoding,$log);

=head4 Arguments

=over 4

=item $dbh

(Object) DBI Database Handle.

=item $encoding

(String) Zeichensatz der Datenbank.

=item $log

(Object) Logger-Objekt

=back

=head4 Returns

Datenbank-Verbindung (Objekt)

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

my $RowNum = 0; # Ist während einer Fetchphase gesetzt

sub new {
    my ($class,$dbh,$encoding,$log) = @_;

    $dbh->{'Warn'} = 0;
    $dbh->{'RaiseError'} = 1;
    $dbh->{'ShowErrorStatement'} = 1;
    $dbh->{'HandleError'} = sub {
        my ($msg,$h) = @_;
        (my $errno = $h->err) =~ s/^-//;
        (my $errstr = $h->errstr) =~ s/\.$//;
        $msg = sprintf 'DB-%05d: %s',$errno,$errstr;
        my $stmt = $1 if $msg =~ /\[for statement "(.+)"\]/si;
        if ($stmt) {
            $msg .= "\n$stmt\n";
        }
        if ($RowNum) { # Fehler beim Fetchen (z.B. kaputter UTF-8 String)
            if ($log) {
                $log->warn(sprintf "Row: %s\n%s",($RowNum+1),$msg);
            }
            else {
                warn sprintf "Row: %s\n%s",($RowNum+1),$msg;
            }
            return 1; # Keine Exception
        }
        die $msg;
    };

    return $class->SUPER::new(
        dbh => $dbh,
        encoding => $encoding,
        logger => $log,
    );
}

# -----------------------------------------------------------------------------

=head2 Datenbank-Operationen

=head3 disconnect() - Schließe Datenbankverbindung

=head4 Synopsis

  $db->disconnect;

=head4 Description

Baue die Datenbank-Verbindung ab. Das Verbindungs-Objekt existiert nach
Aufruf der Methode nicht mehr.

=cut

# -----------------------------------------------------------------------------

sub disconnect {
    $_[0] = undef;
}

# -----------------------------------------------------------------------------

=head3 exec() - Führe SQL-Statement aus

=head4 Synopsis

  $sth = $db->exec($sql);

=head4 Arguments

SQL-Statement (String)

=head4 Returns

Statement-Handle (Objekt)

=head4 Description

Führe SQL-Statement $sql aus und liefere díe Statement-Handle zurück.

=cut

# -----------------------------------------------------------------------------

sub exec {
    my $self = shift;
    my $sql = Kwarq::String->unindent(shift);

    if (my $encoding = $self->{'encoding'}) {
        $sql = Encode::encode($encoding,$sql);
    }

    my $dbh = $self->{'dbh'};

    my $sth;
    eval {
        $sth = $dbh->prepare($sql);
        $sth->execute;
    };
    if ($@) {
        if (index($@,$sql) < 0) {
            # Wenn die Fehlermeldung kein SQL-Statement
            # enthält, fügen wir es hinzu
            $@ .= $sql;
        }
        die $@;
    }

    return $sth;
}

# -----------------------------------------------------------------------------

=head3 select() - Selektiere Datensätze

=head4 Synopsis

  @rows = $db->select($sql);
  $tab = $db->select($sql);

=head4 Returns

Liste von Datensätzen. Im Skalarkontext liefere ein Ergebnismengen-Objekt.

=head4 Description

Selektiere mit Statement $sql Datensätze von der Datenbank und liefere
diese in einer Liste oder als Ergebnismengen-Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub select {
    my $self = shift;
    my $sql = Kwarq::String->unindent(shift,1);

    my $t0 = scalar Time::HiRes::gettimeofday;

    my $encoding = $self->{'encoding'};

    my $sth = $self->exec($sql);

    my (@titles,@rows);
    $RowNum = 0;
    if ($encoding) {
        for my $title (@{$sth->{'NAME_lc'}}) {
            push @titles,Encode::decode($encoding,$title);
        }

        while (my $arr = $sth->fetchrow_arrayref) {
            $RowNum++; # für Ausgabe von Fetchfehlern
            my @keyVal;
            for (my $i = 0; $i < @$arr; $i++) {
                my $val = $arr->[$i] // '';
                push @keyVal,$titles[$i],Encode::decode($encoding,$val);
            }
            push @rows,Kwarq::Database::Row->new(@keyVal);
        }
    }
    else {
        @titles = @{$sth->{'NAME_lc'}};

        while (my $h = $sth->fetchrow_hashref('NAME_lc')) {
            $RowNum++; # für Ausgabe von Fetchfehlern
            for my $key (keys %$h) {
                $h->{$key} //= '';
            }
            push @rows,Kwarq::Database::Row->new($h);
        }
    }
    $RowNum = 0; # Fetchen beendet

    if (wantarray) {
        return @rows;
    }

    return Kwarq::Database::ResultSet->new(\@titles,\@rows,
        $sql,Time::HiRes::gettimeofday-$t0);
}

# -----------------------------------------------------------------------------

=head3 tableExists() - Prüfe, ob Tabelle existiert

=head4 Synopsis

  $bool = $db->tableExists($table);

=head4 Returns

Boolean

=head4 Description

Prüfe, ob Tabelle $table auf der Datenbank existiert,
genauer: zugreifbar ist. Wenn ja, liefere 1, sonst 0.

=cut

# -----------------------------------------------------------------------------

sub tableExists {
    my ($self,$table) = @_;

    local $@;
    eval {$self->select("SELECT 1 FROM $table WHERE 1 = 0")};

    return $@? 0: 1;
}

# -----------------------------------------------------------------------------

=head3 value() - Wert aus Datenbanktabelle

=head4 Synopsis

  $val = $db->value($sql);

=head4 Arguments

=over 4

=item $sql

SQL-Statement, das genau einen Wert selektiert.

=back

=head4 Returns

Kolumnenwert (String)

=head4 Description

Ermittele per SQL-Statement $sql einen einzelnen Wert und liefere
diesen zurück. Es ist ein Fehler, wenn kein Wert oder mehr als ein
Wert gefunden wird.

=cut

# -----------------------------------------------------------------------------

sub value {
    my ($self,$sql) = @_;

    my @values = $self->values($sql);
    if (!@values) {
        die "ERROR: No value found\n";
    }
    elsif (@values > 1) {
        die "ERROR: More than one value found\n";
    }

    return $values[0] // '';
}

# -----------------------------------------------------------------------------

=head3 values() - Werte aus Datenbanktabelle

=head4 Synopsis

  @values | $valueA = $db->values($sql);

=head4 Arguments

=over 4

=item $sql

SQL-Statement, das eine Kolumne selektiert.

=back

=head4 Returns

Liste von Kolumnenwerten (Array of Strings). Im Skalarkontext eine
Referenz auf die Liste.

=head4 Description

Ermittele per SQL-Statement $sql eine Liste von Werten und liefere
diese zurück.

=cut

# -----------------------------------------------------------------------------

sub values {
    my ($self,$sql) = @_;

    my $dbh = $self->{'dbh'};

    my $rowA = $dbh->selectall_arrayref($sql);
    my @values = map {$_->[0]} @$rowA;

    if (my $encoding = $self->{'encoding'}) {
        @values = map {Encode::decode($encoding,$_)} @values;
    }

    return wantarray? @values: \@values;
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
