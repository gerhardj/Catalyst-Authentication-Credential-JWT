package Catalyst::Authentication::Credential::JWT;

use strict;
use warnings;

use base "Class::Accessor::Fast";

__PACKAGE__->mk_accessors(qw/
    debug
    jwt_fields
    store_fields
    jwt_key
    alg
/);

our $VERSION = '0.01';

use Crypt::JWT qw/decode_jwt/;
use TryCatch;
use Catalyst::Exception ();

sub new {
    my ( $class, $config, $c, $realm ) = @_;
    my $self = {
                # defaults:
                jwt_fields => ['username'],
                store_fields => ['username'],
                alg => 'HS256',
                #
                %{ $config },
                %{ $realm->{config} },  # additional info, actually unused
               };
    bless $self, $class;

    return $self;
}

sub authenticate {
    my ( $self, $c, $realm, $authinfo ) = @_;

    $c->log->debug("CredentialJWT::authenticate() called from " . $c->request->uri) if $self->debug;

    my $auth_header = $c->req->header('Authorization');
    return unless ($auth_header);

    my ($token) = $auth_header =~ m/Bearer\s+(.*)/;
    return unless ($token);

    $c->log->debug("Found token: $token") if $self->debug;

    my $jwt_data;
    try {
        $jwt_data = decode_jwt(token=>$token, key=>$self->jwt_key, accepted_alg => $self->alg);
    } catch ($e) {
        # smt happended
        $c->log->debug("Error decoding token: $e") if $self->debug;
        return;
    }

    my $user_data = {
        %{ $authinfo // {} },
    };
    for (my $i = 0; $i < length(@{ $self->jwt_fields }); $i++) {
        $user_data->{$self->store_fields->[$i]} = $jwt_data->{$self->jwt_fields->[$i]};
    }
    my $user_obj = $realm->find_user($user_data, $c);
    if (ref $user_obj) {
        return $user_obj;
    } else {
        $c->log->debug("Failed to find_user") if $self->debug;
        return;
    }
}

1;

__END__

=head1 NAME

Catalyst::Authentication::Credential::JWT

=head1 DESCRIPTION

This authentication credential checker tries to read a JSON Web Token (JWT)
from the current request, verifies its signature and looks up the user
in the configured authentication store.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Catalyst qw/
        Authentication
    /;

    __PACKAGE__->config( 'Plugin::Authentication' => {
        default_realm => 'example',
        realms => {
            example => {
                credential => {
                    class => 'JWT',
                    jwt_key => 'secret' # MUST be changed!!
                },
                store => {
                    class => 'Minimal',
                    users => {
                        bob => { password => 'bobspassword' },
                    },
                },
            },
        }
    });

see also the tests of this module.

=head1 SUBROUTINES/METHODS

=over 4

=item new

bla

=item authenticate

bla

=back

=head1 AUTHOR

Gerhard Jungwirth, C<< <gerhard.jungwirth3 at gmail.com> >>

=head1 BUGS

Please report bugs via Github.

=head1 SUPPORT

For general questions, see resources of Catalyst itself.

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE

Copyright 2017 Gerhard Jungwirth.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

=cut
