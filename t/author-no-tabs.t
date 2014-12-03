
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'bin/bmkpasswd',
    'lib/App/bmkpasswd.pm',
    'lib/Crypt/Bcrypt/Easy.pm',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/01_md5.t',
    't/02_bcrypt.t',
    't/03_sha.t',
    't/04_hashopts.t',
    't/05_oo.t',
    't/06_warn.t',
    't/author-no-tabs.t',
    't/release-cpan-changes.t',
    't/release-dist-manifest.t',
    't/release-pod-coverage.t',
    't/release-pod-linkcheck.t',
    't/release-pod-syntax.t',
    't/release-unused-vars.t'
);

notabs_ok($_) foreach @files;
done_testing;
