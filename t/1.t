use Test::More tests => 11;
BEGIN { require_ok('Sub::Recursive') };

#########################

use strict;
use Sub::Recursive;
use Sub::Recursive qw/ recursive_ /;

ok(defined $REC);
ok(defined &recursive);
ok(defined &_);
ok(defined &recursive_);

sub fac { $_[0] ? $_[0] * _($_[0]-1) : 1 }
my $fac = recursive { $_[0] ? $_[0] * $REC->($_[0]-1) : 1 };
my $fac_ = recursive_ { $_[0] ? $_[0] * _($_[0]-1) : 1 };

ok(fac(5) == 120, 'main, fac(5)');
ok($fac->(5) == 120, 'main, $fac->(5)');
ok($fac_->(5) == 120, 'main, $fac_->(5)');

package Foo;
::ok(::fac(5) == 120, 'Foo, fac(5)');
::ok($fac->(5) == 120, 'Foo, $fac->(5)');
::ok($fac_->(5) == 120, 'Foo, $fac_->(5)');
