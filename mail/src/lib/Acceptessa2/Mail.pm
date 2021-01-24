package Acceptessa2::Mail;
use strict;
use warnings;
use Scalar::Util 'reftype';

# use Paws;
# use Text::Xslate;
# use Email::MIME;
# my $tx = Text::Xslate->new();

sub run {
    my ( $class, $payload ) = @_;

    if ( ( reftype($payload) || '' ) ne 'HASH' ) {
        return { error => 'invalid parameter' };
    }

    my $template = $payload->{template};
    my $data     = $payload->{data};

    if ( !$template || reftype($template) ) {
        return { error => 'template is invalid' };
    }

    if ( ( reftype($data) || '' ) ne 'HASH' ) {
        return { error => 'data is invalid' };
    }

    return 1;
}

1;
