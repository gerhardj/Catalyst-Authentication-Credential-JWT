use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Catalyst::Authentication::Credential::JWT',
    AUTHOR           => q{Gerhard Jungwirth <gerhard.jungwirth3@gmail.com>},
    VERSION_FROM     => 'lib/Catalyst/Authentication/Credential/JWT.pm',
    ABSTRACT_FROM    => 'lib/Catalyst/Authentication/Credential/JWT.pm',
    LICENSE          => 'perl_5',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.006',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'Crypt::JWT' => 0,
        'TryCatch' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Catalyst-Authentication-Credential-JWT-*' },
);
