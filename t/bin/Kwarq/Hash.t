#!/usr/bin/env perl

package Kwarq::Hash::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Hash');
}

# -----------------------------------------------------------------------------

sub test_get : Test(5) {
    my $self = shift;

    my $h = Kwarq::Hash->new(a=>1,b=>2,c=>3);

    my $val = $h->{'b'};
    $self->is($val,2);

    $val = $h->get('b');
    $self->is($val,2);

    $val = eval {$h->get('d')};
    $self->ok($@);

    my @arr = @{$h}{'b','a'};
    $self->isDeeply(\@arr,[2,1]);

    @arr = $h->get('b','a');
    $self->isDeeply(\@arr,[2,1]);
}

# -----------------------------------------------------------------------------

sub test_set : Test(5) {
    my $self = shift;

    my $h = Kwarq::Hash->new(a=>1,b=>2,c=>3);

    $h->set(b=>5);
    $self->is($h->{'b'},5);

    $h->{'b'} = 5;
    $self->is($h->{'b'},5);

    @{$h}{'b','c'} = (6,7);
    $self->is($h->{'b'},6);
    $self->is($h->{'c'},7);

    eval {$h->set(d=>7)};
    $self->ok($@);
}

# -----------------------------------------------------------------------------

sub test_lockKeys : Test(2) {
    my $self = shift;

    my $h = Kwarq::Hash->new(a=>1,b=>2,c=>3);

    $h->lockKeys;

    my $val = $h->{'b'};
    $self->is($val,2,'Key b');

    $val = eval {$h->{'d'}};
    $self->like($@,qr/disallowed key 'd'/,'Key d - Exception');
}

# -----------------------------------------------------------------------------

sub test_unlockKeys : Test(3) {
    my $self = shift;

    my $h = Kwarq::Hash->new(a=>1,b=>2,c=>3);
    $h->lockKeys;

    my $val = $h->{'b'};
    $self->is($val,2,'Key b');

    $val = eval { $h->{'d'} };
    $self->like($@,qr/disallowed key 'd'/,'Key d - Exception');

    $h->unlockKeys;

    $val = $h->{'d'};
    $self->is($val,undef,'Key d - undef');
}

# -----------------------------------------------------------------------------

sub test_AUTOLOAD : Test(3) {
    my $self = shift;

    my $h = Kwarq::Hash->new(a=>1,b=>2,c=>3);

    my $val = $h->a;
    $self->is($val,1);

    $h->a = 3;
    $self->is($h->a,3);

    eval{$h->d};
    $self->like($@,qr/HASH-00001/);
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Hash::Test->runTests;

# eof
