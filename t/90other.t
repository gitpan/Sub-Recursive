use Test::More tests => 1 + 6;
BEGIN { require_ok('Sub::Recursive') };

#########################

use strict;

BEGIN { use_ok('Sub::Recursive', qw/ :ALL /) }

ok(defined $REC, '$REC defined');
ok(defined &recursive, '&recursive defined');

ok(defined %REC, '%REC defined');
ok(defined &mutually_recursive, '&mutually_recursive defined');


sub foo { recursive { 1 } }

($a, $b) = (foo(), foo());

isnt($a, $b);

# This test it to make sure that the same subroutine isn't returned.
# If "recursive" was changed to "sub" in foo, the test would fail for
# at least 5.6.1 and 5.8.0.
