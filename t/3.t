use Test::More tests => 5;
BEGIN { require_ok('Sub::Recursive') };

#########################

use Sub::Recursive;

ok(defined $REC);
ok(defined &recursive);
ok(not defined &_);
ok(not defined &recursive_);
