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
    for (my $i = 0; $i < scalar(@{ $self->jwt_fields }); $i++) {
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

Catalyst::Authentication::Credential::JWT - authenticate to a Catalyst
application via JWT

=head1 DESCRIPTION

This authentication credential checker tries to read a JSON Web Token (JWT)
from the current request, verifies its signature and looks up the user
in the configured authentication store. Only tested with JWS so far. (For JWE
some adaptions to this module may be neccessary.)

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

    sub foo : Local {
        my ( $self, $c ) = @_;

        $c->authenticate({}, "example");

        do_stuff();
    }

see also the tests of this module. The task of creating new tokens to users is
up to you, but you will probably write something like this:

    use JSON qw/encode_json decode_json/;
    use Crypt::JWT qw/encode_jwt/;

    sub auth_jwt :Chained('/') :PathPart('auth_jwt') :Args(0) :Method('POST') {
        my ($self, $c) = @_;

        my $user = $c->req->body_data->{username} // '';
        my $pass = $c->req->body_data->{password} // '';

        my $key = 'secret'; # CHANGE THIS!!!

        $c->response->content_type('application/json');

        ...
        # error checking
        # checking valid credential from db

        my $result = {};

        if ($auth_credentials_valid) {
            my $jwt_data = {
                username => $user,
            };
            $result->{jwt} = encode_jwt(
                payload => $jwt_data,
                key => $key,
                alg => $alg,
            );
        } else {
            $c->response->status(HTTP_FORBIDDEN);
            $c->response->body(encode_json({ code => HTTP_FORBIDDEN,
                message => "User not found" })."\n");
            $c->log->error("User not found");
            return;
        }

        $c->res->body(encode_json($result));
        $c->res->code(HTTP_OK);  # 200

        return;
    }

=head1 CONFIGURATION

Configuration is done through Catalyst configuration as seen in the synopsis. This module is activated
by setting C<class> to C<JWT>. Some further options are available:

=over 4

=item jwt_key

Required. Take care, to have a sufficiently high entropy. For more
details, read some tutorials about JWT.

=item jwt_fields

Array of fields in the token, which are used to find a matching user
in the store.
Default: C<['username']>

=item store_fields

Array of fields in the store, to which the C<jwt_fields> are
matched against. In other words, the keys, which are passed
to C<find_user> of the store.
Default: C<['username']>

=item alg

List of accepted JWS algorithms. Can be a string, array or Regex.
For more details, see documentation of L<Crypt::JWT|Crypt::JWT#accepted_alg>.

=item debug

If set to a true value, some debug output is generated.

=back

=head1 SUBROUTINES/METHODS

=over 4

=item new

Constructor. You don't need to call this yourself. Just plug the module in
your Catalyst authentication framework. Also see L<Catalyst::Plugin::Authentication|Catalyst::Plugin::Authentication>.

=item authenticate

Searches for a valid JSON web token in the Authorization header with the Bearer scheme. If found, uses
the specified fields to lookup the given user in the store using the find_user method. This is also called
through the authentication plugin with C<< $c->authenticate(...) >>.

=back

=head1 AUTHOR

Gerhard Jungwirth, C<< <gerhard.jungwirth3 at gmail.com> >>

=head1 BUGS

Please report bugs via Github.

=head1 SUPPORT

For general questions, see resources of Catalyst itself.

For more Information about JWT, got to jwt.io

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE

Copyright 2017 Gerhard Jungwirth.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut
