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
