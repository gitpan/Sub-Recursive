#!/usr/bin/perl

use strict;
use warnings;
use Benchmark qw(cmpthese);

use Sub::Recursive;
use Sub::Recursive qw/ _ /;
use Sub::Recursive qw/ recursive_ /;

use vars qw/ $rec /;

sub manual_recursive {
    my $_foo = sub { @_ ? $_[0] + $rec->(@_[1 .. $#_]) : 0 };
    return sub {
        local $rec = $_foo;
        $_foo->(@_);
    };
}

sub leaker {
    my $_foo;
    $_foo = sub { @_ ? $_[0] + $_foo->(@_[1 .. $#_]) : 0 };
    return $_foo;
}

sub named { @_ ? $_[0] + _(@_[1 .. $#_]) : 0 }

my $leaker = leaker();
my $manual = manual_recursive();
my $recursive = recursive { @_ ? $_[0] + $REC->(@_[1 .. $#_]) : 0 };
my $recursive_ = recursive_ { @_ ? $_[0] + _(@_[1 .. $#_]) : 0 };
my $named = \&named;

my @vals = 1 .. 50;

cmpthese(-10, {
    leaker => sub { $leaker->(@vals) },
    manual => sub { $manual->(@vals) },
    recursive => sub { $recursive->(@vals) },
    recursive_ => sub { $recursive_->(@vals) },
    named => sub { $named->(@vals) },
});

__END__
             Rate recursive_      named     manual     leaker  recursive
recursive_  375/s         --        -3%       -69%       -70%       -70%
named       386/s         3%         --       -68%       -69%       -69%
manual     1215/s       224%       215%         --        -1%        -3%
leaker     1233/s       229%       220%         1%         --        -1%
recursive  1247/s       232%       223%         3%         1%         --
