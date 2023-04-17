#!/usr/bin/env perl

package Kwarq::Logger::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Logger');
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Logger::Test->runTests;

# eof
