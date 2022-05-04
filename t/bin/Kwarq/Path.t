#!/usr/bin/env perl

package Kwarq::Path::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Kwarq::Path');
}

# -----------------------------------------------------------------------------

sub test_mkdir : Test(2) {
    my $self = shift;

    my $path = "/tmp/mkdir$$/a/b";
    eval {Kwarq::Path->mkdir($path)};
    $self->like($@,qr/PATH-00001/);

    $path = "/tmp/mkdir$$";
    Kwarq::Path->mkdir($path);
    $self->is(-d $path,1);

    Kwarq::Path->delete("/tmp/mkdir$$");
}

# -----------------------------------------------------------------------------

sub test_delete : Test(5) {
    my $self = shift;

    eval {Kwarq::Path->delete('/does/not/exist')};
    $self->ok(!$@);

    # Testverzeichnis erzeugen

    (my $dir) = (my $path) = "/tmp/test_delete$$";
    mkdir $path;
    for (qw/a b c/) {
        $path .= "/$_";
        mkdir $path;
    }
    my $file = "$path/f.txt";
    Kwarq::Path->write($file,"bla\n");

    # Datei

    $self->ok(-e $file);

    Kwarq::Path->delete($file);
    $self->ok(!-e $file);

    # Verzeichnis

    $self->ok(-e $dir);

    Kwarq::Path->delete($dir);
    $self->ok(!-e $dir);
}

# -----------------------------------------------------------------------------

sub test_expandTilde : Test(2) {
    my $self = shift;

    my $path1 = '/test';
    my $path2 = Kwarq::Path->expandTilde('/test');
    $self->is($path1,$path2);

    $path1 = '~/test';
    $path2 = Kwarq::Path->expandTilde('~/test');
    $self->isnt($path1,$path2);
}

# -----------------------------------------------------------------------------

package main;
Kwarq::Path::Test->runTests;

# eof
