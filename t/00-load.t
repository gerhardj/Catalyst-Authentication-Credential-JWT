#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Catalyst::Authentication::Credential::JWT' ) || print "Bail out!\n";
}

diag( "Testing Catalyst::Authentication::Credential::JWT $Catalyst::Authentication::Credential::JWT::VERSION, Perl $], $^X" );
