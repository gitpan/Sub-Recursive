use Test::More tests => 5;
BEGIN { require_ok('Sub::Recursive') };

#########################

use Sub::Recursive qw/ _ /;

scalar $REC; # suppress warning.

ok(not defined $REC);
ok(not defined &recursive);
ok(defined &_);
ok(not defined &recursive_);
