#!/usr/bin/env perl

package Kwarq::Program::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Program');
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Program::Test->runTests;

# eof
