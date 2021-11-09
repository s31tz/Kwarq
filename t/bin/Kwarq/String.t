#!/usr/bin/env perl

package Kwarq::String::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::String');
}

# -----------------------------------------------------------------------------

sub test_unindentReplace: Test(5) {
    my $self = shift;

    my $str = Kwarq::String->unindentReplace(undef);
    $self->is($str,undef);

    $str = Kwarq::String->unindentReplace('');
    $self->is($str,'');

    # Unindent-Funktionalität

    $str = Kwarq::String->unindentReplace("  \n\nabc\ndef  ");
    $self->is($str,"abc\ndef");

    $str = Kwarq::String->unindentReplace("

        SELECT
            *
        FROM
            person
        WHERE
            nachname = 'Schulz'

    ");
    $self->is($str,"SELECT\n    *\nFROM\n    person\nWHERE\n".
        "    nachname = 'Schulz'");

    # Replace-Funktionalität

    $str = Kwarq::String->unindentReplace(q~
        SELECT
            *
        FROM
            __TABLE__
        WHERE
            nachname = '__NACHNAME__'

        ~,
        __TABLE__ => 'person',
        __NACHNAME__ => 'Schulz',
    );
    $self->is($str,"SELECT\n    *\nFROM\n    person\nWHERE\n".
        "    nachname = 'Schulz'");
}

# -----------------------------------------------------------------------------

package main;
Kwarq::String::Test->runTests;

# eof
