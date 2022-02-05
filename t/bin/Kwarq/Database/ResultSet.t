#!/usr/bin/env perl

package Kwarq::Database::ResultSet::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Database::ResultSet');
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Database::ResultSet::Test->runTests;

# eof
