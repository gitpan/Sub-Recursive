use Test::More tests => 5;
BEGIN { require_ok('Sub::Recursive') };

#########################

use strict;
use Sub::Recursive;

ok(defined $REC, '$REC defined');
ok(defined &recursive, '&recursive defined');

my $fac = recursive { $_[0] ? $_[0] * $REC->($_[0]-1) : 1 };

ok($fac->(5) == 120, 'main, $fac->(5)');

package Foo;
::ok($fac->(5) == 120, 'Foo, $fac->(5)');
