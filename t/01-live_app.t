#!/usr/bin/perl
use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
BEGIN {
    do {
        eval { require Test::WWW::Mechanize::Catalyst }
        and
        Test::WWW::Mechanize::Catalyst->VERSION('0.51')
    }
      or plan skip_all =>
      "Test::WWW::Mechanize::Catalyst is needed for this test";
}
use HTTP::Request;

use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'TestApp');

diag('basic request');
{
    my $r = HTTP::Request->new( GET => "http://localhost/" );
    $mech->request($r);    
    is( $mech->status, 200, "status is 200" ) or die $mech->content;
    $mech->content_contains( "Hello", "content 'Hello' sent" );
}

diag('forbidden request');
{
    my $r = HTTP::Request->new( GET => "http://localhost/my_secret" );
    $mech->request($r);    
    is( $mech->status, 401, "status is 401" ) or die $mech->content;
    $mech->content_lacks( "secret", "content not sent" );
}

diag('invalid jwt');
{
    my $r = HTTP::Request->new( GET => "http://localhost/my_secret" );
    $r->header('Authorization' => 'Bearer asdf.asdf.asdf');
    $mech->request($r);    
    is( $mech->status, 401, "status is 401" ) or die $mech->content;
    $mech->content_lacks( "secret", "content not sent" );
}

diag('jwt with invalid signature');
{
    my $r = HTTP::Request->new( GET => "http://localhost/my_secret" );
    my $token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImJvYiJ9.MIrpD02FnrYua3sZnF8Q52VJVLRECvqrA49X7cfifPM';
    # {"username": "bob"}
    $r->header('Authorization' => "Bearer $token");
    $mech->request($r);    
    is( $mech->status, 401, "status is 401" ) or die $mech->content;
    $mech->content_lacks( "secret", "content not sent" );
}

diag('jwt with wrong user');
{
    my $r = HTTP::Request->new( GET => "http://localhost/my_secret" );
    my $token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImRvbmFsZCJ9.Yzz4aeiOdvjvh_BKzOl8pI_yL4q0TujVKHZkOp7M0zw';
    # {"username": "donald"}
    $r->header('Authorization' => "Bearer $token");
    $mech->request($r);    
    is( $mech->status, 401, "status is 401" ) or die $mech->content;
    $mech->content_lacks( "secret", "content not sent" );
}

diag('jwt with valid token');
{
    my $r = HTTP::Request->new( GET => "http://localhost/my_secret" );
    my $token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImJvYiJ9.kV_eCSvTgJolfqWCPrx2bcbkdGj7H4gw-ZiheQDy7P4';
    # {"username": "donald"}
    $r->header('Authorization' => "Bearer $token");
    $mech->request($r);    
    is( $mech->status, 200, "status is 200" ) or die $mech->content;
    $mech->content_contains( "super-secret", "content sent" );
}


done_testing;

