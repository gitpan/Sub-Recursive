use Test::More tests => 5;
BEGIN { require_ok('Sub::Recursive') };

#########################

use Sub::Recursive ();

scalar $REC; # suppress warning.

ok(not defined $REC);
ok(not defined &recursive);
ok(not defined &_);
ok(not defined &recursive_);
