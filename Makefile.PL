use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Sub::Recursive',
    VERSION_FROM => 'lib/Sub/Recursive.pm', # finds $VERSION
    AUTHOR       => 'Johan Lodin <lodin@cpan.org>',
    ABSTRACT     => 'Sub::Recursive',
    PREREQ_PM    => {
                    },
);
