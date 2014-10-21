use Test::More tests => 2;
BEGIN { require_ok('Sub::Recursive') };

#########################

use strict;
use Sub::Recursive;

sub foo { recursive { 1 } }

($a, $b) = (foo(), foo());

ok($a != $b);

# This test it to make sure that the same subroutine isn't returned.
# If "recursive" was changed to "sub" in foo, the test would fail for
# at least 5.6.1 and 5.8.0.
