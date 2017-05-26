package TestApp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub auto :Private {
    my ($self, $c) = @_;

    $c->authenticate({});

    return 1;
}

sub my_index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    # $c->response->body( $c->welcome_message );
    $c->response->body('Hello World');
}

sub my_secret :Local :Args(0) {
    my ($self, $c) = @_;

    $c->detach("unauthorized")
        unless $c->user_exists;
    $c->response->body("This is super-secret");
}

sub end : ActionClass('RenderView') {}

sub unauthorized :Private {
    my ($self, $c) = @_;

    $c->response->code(401);
    $c->response->body("forbidden: unauthorized");
}



__PACKAGE__->meta->make_immutable;

1;


=encoding utf-8

=head1 NAME

TestApp::Controller::Root - Root Controller for TestApp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut


=head2 default

Standard 404 error page

=cut

=head2 end

Attempt to render a view, if needed.

=cut

=head1 AUTHOR

Gerhard,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut