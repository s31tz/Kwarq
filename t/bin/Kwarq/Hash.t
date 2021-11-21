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
