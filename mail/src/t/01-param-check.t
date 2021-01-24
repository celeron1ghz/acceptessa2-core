use strict;
use Test::More;
use Test::LongString;
use Acceptessa2::Mail;
use YAML;

sub cr2crlf {
    my $val = shift;
    return join("\r\n", split "\n", $val) . "\r\n";
}

my $data  = YAML::Load(join "", <DATA>);
my @tests = (
    {
        template  => $data->{tmpl1},
        expected  => cr2crlf($data->{result1}),
        desc      => 'basic template',
        parameter => {
            from     => 'from@from',
            to       => 'to@to',
            subject  => 'subject subject',
            template => "z",
            data     => {
                hello => "mogemoge",
                world => "fugafuga",
            }
        },
        ret => { success => 1 },
    },
);

plan tests => @tests * 2;
local *Email::Simple::Creator::_date_header = sub { 'ThisIsDateString' };

foreach my $t (@tests) {
    my $result;
    local *Acceptessa2::Mail::get_template = sub { $t->{template} };
    local *Acceptessa2::Mail::send_mail    = sub { $result = $_[1] };

    my $ret = Acceptessa2::Mail->run($t->{parameter});
    is_deeply $ret, $t->{ret}, "$t->{desc}: return value ok";
    is_string $t->{expected}, $result, "$t->{desc}:   template render ok";
}

__DATA__
tmpl1: |
  <!-- subject subject -->
  <: $hello :> <: $world :>
result1: |
  From: from@from
  To: to@to
  Subject: subject subject
  Date: ThisIsDateString
  MIME-Version: 1.0
  Content-Transfer-Encoding: base64
  Content-Type: text/html; charset=utf-8
  
  bW9nZW1vZ2UgZnVnYWZ1Z2EK
