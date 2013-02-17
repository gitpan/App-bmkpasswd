
use strict;
use warnings;

use 5.008005;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "bcrypt-capable mkpasswd(1) and exported helpers",
  "AUTHOR" => "Jon Portnoy <avenj\@cobaltirc.org>",
  "BUILD_REQUIRES" => {
    "Test::More" => "0.88"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-bmkpasswd",
  "EXE_FILES" => [
    "bin/bmkpasswd"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::bmkpasswd",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Crypt::Eksblowfish" => "0.003",
    "Crypt::Random::Seed" => "0.03",
    "Exporter" => 0,
    "Getopt::Long" => "2.24",
    "Term::ReadKey" => 0,
    "Time::HiRes" => 0,
    "Try::Tiny" => 0,
    "strictures" => 1
  },
  "VERSION" => "1.081001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



