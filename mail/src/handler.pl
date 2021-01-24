use utf8;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Acceptessa2::Mail;

$| = 1;

sub handle {
    my $payload = shift;
    $ret = Acceptessa2::Mail->run($payload);
    return $ret;
}

1;
