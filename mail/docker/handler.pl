use utf8;
use warnings;
use strict;

sub handle {
    my $payload = shift;
    print "log test from perl";
    return +{"hello" => "lambda"};
}

1;