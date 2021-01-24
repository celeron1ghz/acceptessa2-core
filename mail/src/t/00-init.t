use strict;
use Test::More;
use Acceptessa2::Mail;

plan tests => 15;

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

is_deeply +Acceptessa2::Mail->run( { template => "z", data => {} } ), { error => "error on get template: 404 InvalidContent" };
is_deeply +Acceptessa2::Mail->run( { template => "template.tt", data => {test => 111222333} } ), 1;
