use utf8;
use warnings;
use strict;

sub handle {
    my $payload = shift;
    print "log test";
    return +{"hello" => "lambda"};
}

1;