use strict;
use Test::More;
use Acceptessa2::Mail;

plan tests => 14;

is_deeply +Acceptessa2::Mail->run(),           { error => 'invalid parameter' };
is_deeply +Acceptessa2::Mail->run(undef),      { error => 'invalid parameter' };
is_deeply +Acceptessa2::Mail->run("mogemoge"), { error => 'invalid parameter' };
is_deeply +Acceptessa2::Mail->run( \my $a ),   { error => 'invalid parameter' };
is_deeply +Acceptessa2::Mail->run( [] ),       { error => 'invalid parameter' };

is_deeply +Acceptessa2::Mail->run( {} ), { error => 'template is invalid' };
is_deeply +Acceptessa2::Mail->run( { template => undef } ),  { error => 'template is invalid' };
is_deeply +Acceptessa2::Mail->run( { template => \my $a } ), { error => 'template is invalid' };
is_deeply +Acceptessa2::Mail->run( { template => [] } ),     { error => 'template is invalid' };
is_deeply +Acceptessa2::Mail->run( { template => {} } ),     { error => 'template is invalid' };

is_deeply +Acceptessa2::Mail->run( { template => "a", data => undef } ),  { error => 'data is invalid' };
is_deeply +Acceptessa2::Mail->run( { template => "a", data => \my $a } ), { error => 'data is invalid' };
is_deeply +Acceptessa2::Mail->run( { template => "a", data => [] } ),     { error => 'data is invalid' };

is_deeply +Acceptessa2::Mail->run( { template => "a", data => {} } ), 1;
