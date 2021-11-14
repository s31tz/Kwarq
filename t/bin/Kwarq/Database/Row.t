#!/usr/bin/env perl

package Kwarq::Database::Row::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Database::Row');
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Database::Row::Test->runTests;

# eof
