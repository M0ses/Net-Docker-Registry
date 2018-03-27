#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Net::Docker::Registry' ) || print "Bail out!\n";
    use_ok( 'Net::Docker::Registry::Client' ) || print "Bail out!\n";
}

diag( "Testing Net::Docker::Registry $Net::Docker::Registry::VERSION, Perl $], $^X" );
