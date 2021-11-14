#!/usr/bin/env perl

package Kwarq::Database::Connection::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Database::Connection');
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Database::Connection::Test->runTests;

# eof
