#!/usr/bin/env perl

package Kwarq::Config::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Config');
}

# -----------------------------------------------------------------------------

sub test_get : Test(2) {
    my $self = shift;

    my $cfg = bless {
        databases => {
            M3 => {
                server => 'as4d2',
                user => 'SVCM3_03',
                password => 'geheim',
            },
        },
    },'Kwarq::Config';

    my $val = $cfg->get('databases','M3','server');
    $self->is($val,'as4d2');

    eval {$cfg->get('databases','UNBEKANNT','server')};
    $self->like($@,qr/Path does not exist/);
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Config::Test->runTests;

# eof
