package Mail;
use strict;
use Mouse;

has from    => ( is => 'ro', isa => 'Str', required => 1 );
has to      => ( is => 'ro', isa => 'Str', required => 1 );
has subject => ( is => 'ro', isa => 'Str', required => 1 );

1;

package main;
use utf8;
use warnings;
use strict;

use Paws;
use Text::Xslate;
use Email::MIME;

use Scalar::Util 'reftype';

$| = 1;

my $tx = Text::Xslate->new();

sub handle {
    my $payload = shift;

    if ( reftype($payload) ne 'ARRAY' ) {
        return { error => 'invalid parameter' };
    }

    my $template = $payload->{template};
    my $data     = $payload->{data};

    if ( reftype($template) ) {
        return { error => 'template is invalid' };
    }

    if ( reftype($data) ne 'HASH' ) {
        return { error => 'data is invalid' };
    }

    my $mail = eval {
        Mail->new($payload);
    };

    warn $mail;
    warn $@, "aaaaaa";

    return +{ "hello" => "lambda" };
}

1;
