use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Kwarq',
    VERSION_FROM => 'lib/Kwarq.pm',
    MIN_PERL_VERSION => 5.10.0,
    BUILD_REQUIRES => {
        ExtUtils::MakeMaker => 6.48, # wg. MIN_PERL_VERSION
    },
    PREREQ_PM => {
    },
    ABSTRACT_FROM => 'lib/Kwarq.pm',
    AUTHOR => 'Frank Seitz <fs@fseitz.de>',
    LICENSE => 'perl_5',
    clean => { FILES => 'Kwarq-*' },
    test => {
        RECURSIVE_TEST_FILES => 1,
    },
    META_MERGE => {
        'meta-spec' => {
            version => 2,
        },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/s31tz/Kwarq.git',
                web  => 'https://github.com/s31tz/Kwarq',
            },
        },
    },
    META_ADD => {
        provides => {
            __MODULES__
        },
    },
);

# eof
