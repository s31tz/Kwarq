#!/usr/bin/env perl

package Kwarq::Shell::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Shell');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(3) {
    my $self = shift;

    my $sh = Kwarq::Shell->new;
    $self->is(ref($sh),'Kwarq::Shell');

    my ($stdout,$stderr) = $sh->exec('ls');
    $self->ok($stdout);
    $self->is($stderr,'');
}

# -----------------------------------------------------------------------------

sub test_check : Test(2) {
    my $self = shift;

    system('true');
    eval {Kwarq::Shell->check($?) };
    $self->ok(!$@);

    system('false');
    eval {Kwarq::Shell->check($?) };
    $self->like($@,qr/CMD-00002/);
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Shell::Test->runTests;

# eof
