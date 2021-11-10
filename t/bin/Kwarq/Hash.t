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

package main;
Kwarq::Hash::Test->runTests;

# eof
