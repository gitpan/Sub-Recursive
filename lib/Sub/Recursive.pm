package Sub::Recursive;

$VERSION = 0.01;

use 5.006;
use strict;
use Carp;
use base 'Exporter';

# Don't export &_, *_ is forced to main:: anyway.
our @EXPORT = qw/ recursive $REC /;
our @EXPORT_OK = qw/ recursive_ /;

our $REC = '$REC is a special variable used by ' . __PACKAGE__;

our $rec = sub {
    my $clr = (caller(1))[3];
    if ($clr =~ /::__ANON__\z/) {
        croak("Can't use &_ on unrecursive anonymous subroutine");
    }
    else {
        goto &$clr;
    }
};

{
    my $underscore = sub { goto &$rec };

    sub import {
        my $class = shift;
        my %args = map { $_ => 1 } @_;

        if ($args{_} or $args{recursive_}) {
            if (\&_ != $underscore) {
                carp('&_ is already defined by someone else')
                    if defined &_;
                no warnings 'redefine';
                *_ = $underscore;
            }
        }

        return if delete $args{_} and not %args;

        __PACKAGE__->export_to_level(1, $class, keys %args);
    }
}

sub recursive_ (&) {
    my ($code) = @_;
    my $foo = sub {
        my $clr = (caller(1))[3];
        if ($clr =~ /::__ANON__\z/) {
            $code->(@_);
        }
        else {
            goto &$clr;
        }
    };
    no warnings 'redefine';
    return sub {
        local $rec = $foo;
        $code->(@_);
    };
}

sub recursive (&) {
    my ($code) = @_;
    my $REC = do { no strict 'refs'; \*{caller() . '::REC'} };
    return sub {
        local *$REC = \$code;
        $code->(@_);
    };
}

1;

__END__

=head1 NAME

Sub::Recursive - Anonymous memory leak free recursive subroutines


=head1 SYNOPSIS

    use Sub::Recursive;

    # Fast LEAK FREE recursive closure.
    my $fac = recursive {
        my ($n) = @_;
        return 1 if $n < 1;
        return $n * $REC->($n - 1);
    };

    # Recursive anonymous definition in one line, plus invocation.
    print recursive { $_[0] <= 1 ? 1 : $_[0] * $REC->($_[0] - 1) } -> (5);

    ########################################

    use Sub::Recursive '_';

    # Slow named recursive function. Uses Perl 6's magical &_ subroutine.
    sub fac {
        my ($n) = @_;
        return 1 if $n < 1;
        return $n * _($n - 1);
    }

    ########################################

    use Sub::Recursive 'recursive_';

    # Exactly the same code between the braces as for &fac.
    # Really slow.
    # Note the trailing underscore on recursive_.
    my $slow_and_bad = recursive_ {
        my ($n) = @_;
        return 1 if $n < 1;
        return $n * _($n - 1);
    };


=head1 DESCRIPTION

Recursive closures suffer from a severe memory leak. C<Sub::Recursive> makes the problem go away cleanly and at the same time allows you to write recursive subroutines as expression and can make them truly anonymous. There's no significant speed difference between using C<&recursive> and writing the simpler leaking solution.

This module has been extended to also provide the Perl 6 C<&_> magical subroutine. It is an alias for the current subroutine. I don't recommend anyone to use C<&_> in Perl 5, but now you at least can taste it.


=head2 The problem

The following won't work:

    my $fac = sub {
        my ($n) = @_;
        return 1 if $n < 1;
        return $n * $fac->($n - 1);
    };

because of the recursive use of C<$fac> which isn't available until after the statement. The common fix is to do

    my $fac;
    $fac = sub {
        my ($n) = @_;
        return 1 if $n < 1;
        return $n * $fac->($n - 1);
    };

Unfortunately, you introduce another problem.

Because of perl's reference count system, the code above is a memory leak. C<$fac> references the anonymous sub which references C<$fac>, thus creating a circular reference. This module does not suffer from that memory leak.

There are two more reasons why I don't like to write recursive closures like that: (a) you have to first declare it, then assign it thus requiring more than a simple expression (b) you have to name it one way or another.

=head2 The solution

This module fixes all those issues. Just change C<sub> for C<recursive> and use C<&$REC> for the recursive call:

    use Sub::Recursive;

    my $fac = recursive {
        my ($n) = @_;
        return 1 if $n < 1;
        return $n * $REC->($n - 1);
    };

Note that you don't even have to give it a name. You can e.g. pass it directly to a subroutine,

    foo(recursive { ... });

just as any other anonymous subroutine.


=head1 EXPORTS

If no arguments are given to the C<use> statement C<$REC> and C<&recursive> are exported. If any arguments are given only those given are exported.

=head2 C<$REC> - exported by default

C<$REC> holds a reference to the current subroutine for subroutines created with C<&recursive>.

=head2 C<recursive> - exported by default

C<&recursive> takes one argument and that's an anonymous sub. It's prototyped with C<&> so bare-block calling style is allowed:

    recursive { ... }

The return value is an anonymous closure that has C<&$REC> working in it.

=head2 C<recursive_>

C<&recursive_> is like C<&recursive> except that C<&_> is used instead of C<&$REC>. It also implies C<_> in the import list.

Subroutines created with C<&recursive_> are very slow and the C<caller> traceback will contain doubly function calls for every call to the anonymous subroutine.

=head2 C<_>

C<&_> isn't exactly exported, it's just defined. The name "_" is forced into the main namespace so all packages use the same variable. This is why C<$_> works the way it works. So by introducing C<&_> in your package you introduce it in every package--not that I think that any other package defines C<&_>...

Don't use this is serious code.


=head1 EXAMPLE

Some algorithms are perhaps best written recursively. For simplicity, let's say I have a tree consisting of arrays of array with arbitrary depth. I want to map over this data structure, translating every value to another. For this I use

    my $translator = recursive { [ map {
        ref() ? $REC->($_) : do {
            $translate{$_}
        }
    } @{$_[0]} ] };

    my $bar = $translator->($foo);

Now, a tree mapper isn't perhaps the best example as it's a pretty general problem to solve, and should perhaps be abstracted but it still serves as an example of how this module can be handy.

A similar but more specialized task would be to find all men who share their Y chromosome.

    # A person data structure look like this.
    my $person = {
        name => ...,
        sons => [ ... ],        # objects like $person
        daughters => [ ... ],   # objects like $person
    };

    my @names = recursive {
        my ($person) = @_;

        $person->{name},
        map $REC->($_), @{$person->{sons}}
    } -> ($forefather);

This particular example isn't a closure as it doesn't reference any lexicals outside itself (and thus could've been written as a named subroutine). It's easy enough to think of a case when it would be a closure though. For instance if some branches should be excluded. A simple flag would solve that.

    my %exclude = ...;

    my @names = recursive {
        my ($person) = @_;

        return if $exclude{$person};

        $person->{name},
        map $REC->($_), @{$person->{sons}}
    } -> ($forefather);

Hopefully this illustrates how this module allows you to write recursive algorithms inline like any other algorithm.


=head1 DIAGNOSTICS

=over

=item Can't use &_ on unrecursive anonymous subroutine

(F) Change C<sub> to C<recursive_> in the definition.

=item &_ is already defined by someone else

(W|S) You wanted this module to define C<&_> but it was already defined by someone else. C<&_> was redefined to be what you asked for.

=back


=head1 WARNING

Using C<&_> is slow! REALLY REALLY SLOW!!! See misc/bench.pl in this distribution.

Using C<&$REC> however is just as fast as not using this module and solving the problem manually. Don't get the habit of using C<recursive> instead of C<sub> though then C<sub> is enough as it imposes an overhead.


=head1 AUTHOR

Johan Lodin <lodin@cpan.org>


=head1 COPYRIGHT

Copyright 2004 Johan Lodin. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 SEE ALSO

L<perlref>


=cut