use Test::More tests => 4;

BEGIN {
  use_ok( 'App::bmkpasswd', qw/mkpasswd passwdcmp/ );
}

my $md5;
ok( $md5 = mkpasswd('snacks', 'md5'), 'MD5 crypt()' );
ok( passwdcmp('snacks', $md5), 'MD5 compare' );
ok( !passwdcmp('things', $md5), 'MD5 negative compare' );
