use utf8;
use warnings;
use strict;
$| = 1;

sub handle {
    my $payload = shift;
    print "log test from perl";
    return +{"hello" => "lambda"};
}

1;