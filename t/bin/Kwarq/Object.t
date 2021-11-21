#!/usr/bin/env perl

package Kwarq::Object::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Object');
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Object::Test->runTests;

# eof
