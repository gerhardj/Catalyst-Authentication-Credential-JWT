package TestApp;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# -Debug: activates the debug mode for very useful log messages
use Catalyst qw/
    Authentication
    Authorization::Roles
/;

extends 'Catalyst';

our $VERSION = '0.01';


__PACKAGE__->config(
    name => 'TestApp',
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header

    'Plugin::Authentication' => {
        default_realm => 'my_jwt',
        my_jwt => {
            credential => {
                class => 'JWT',
                jwt_key => "password",
                debug => 1,
            },
            store => {
                class => 'Minimal',
                users => {
                    bob => {
                        password => "bobpass",
                        editor => 'yes',
                        roles => [qw/edit/],
                    },
                    william => {
                        password => "williampass",
                        roles => [],
                    },
                },
            },
            use_session => 0,
        }
    }
);

__PACKAGE__->setup();

=encoding utf8

=head1 NAME

TestApp - Catalyst based application

=head1 SYNOPSIS

    script/testapp_server.pl

=head1 DESCRIPTION

Test application for Catalyst::Authentication::Credential::JWT

=head1 SEE ALSO

L<Catalyst::Authentication::Credential::JWT>, L<Catalyst>

=head1 AUTHOR

Gerhard,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
