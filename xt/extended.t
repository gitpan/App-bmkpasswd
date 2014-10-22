use Test::More;
use strict; use warnings;

use Benchmark 'timethis';

BEGIN {
  diag "\n",
    "This test will need a solid source of entropy; try haveged.\n",
    ' . . . or wiggling your mouse a lot \o/', "\n\n";
  use_ok( 'App::bmkpasswd', qw/mkpasswd passwdcmp/ );
  sleep 2;
}

(sub {
SKIP: {
  App::bmkpasswd::have_passwd_xs();
  if ( ! App::bmkpasswd::have_passwd_xs() ) {
    ## Apparently Win32 has a functional crypt() uh, "sometimes"
    unless ( index(mkpasswd('a', 'md5', 0, 1), '$1$') == 0) {
      skip( "No MD5 support", 4 );
    }
  }

  my $md5;
  ok( $md5 = mkpasswd('snacks', 'md5', 0, 0), 'MD5 crypt()' );
  ok( index($md5, '$1$') == 0, 'Looks like MD5' );
  ok( $md5 = mkpasswd('snacks', 'md5', 0, 1), 'MD5 crypt() strong' );
  ok( passwdcmp('snacks', $md5), 'MD5 compare' );
  ok( !passwdcmp('things', $md5), 'MD5 negative compare' );
}

my $bc;
ok( $bc = mkpasswd('snacks', 'bcrypt', 2, 0), 'Bcrypt tuned' );
ok( passwdcmp('snacks', $bc), 'Bcrypt tuned workcost compare' );
ok( $bc = mkpasswd('snacks', 'bcrypt', 2, 1), 'Bcrypt tuned strong' );
ok( !passwdcmp('things', $bc), 'Bcrypt tuned negative compare' );

SKIP: {
  unless ( App::bmkpasswd::have_sha(256) ) {
    skip( "No SHA support", 4 );
  }
  my $sha256;
  ok( $sha256 = mkpasswd('snacks', 'sha256', 0, 1), 'SHA256 strong' );
  ok( passwdcmp('snacks', $sha256), 'SHA256 compare' );
  ok( $sha256 = mkpasswd('snacks', 'sha256', 0, 0), 'SHA256' );
  ok( !passwdcmp('things', $sha256), 'SHA256 negative compare' );
}
})->() for 1 .. 100;
done_testing;
