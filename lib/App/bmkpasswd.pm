package App::bmkpasswd;
our $VERSION = '1.07';

use strictures 1;

use Carp;

use Try::Tiny;

use Crypt::Eksblowfish::Bcrypt qw/bcrypt en_base64/;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/
  mkpasswd
  passwdcmp
/;

our $HAVE_PASSWD_XS;

sub have_passwd_xs {
  $HAVE_PASSWD_XS = 0;

  try {
    require Crypt::Passwd::XS;
    $HAVE_PASSWD_XS = 1
  };
  
  return $HAVE_PASSWD_XS
}

sub mkpasswd {
  my ($pwd, $type, $cost) = @_;
  
  $type = 'bcrypt' unless $type;
  
  # a default (randomized) salt
  # can be used for md5 or built on for SHA
  my @chrs = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9, '.', '/' );
  my $salt = join '', map { $chrs[rand @chrs] } 1 .. 8;
  
  TYPE: {
    if ($type =~ /^bcrypt$/i) {
      $cost = '08' unless $cost;

      croak "Work cost factor must be numeric"
        unless $cost =~ /^[0-9]+$/;

      $cost = '0$cost' if length $cost == 1;
      $salt = en_base64( join '', map { chr int rand 256 } 1 .. 16 );
      my $bsettings = join '', '$2a$', $cost, '$', $salt;

      return bcrypt($pwd, $bsettings)
    }

    # SHA requires Crypt::Passwd::XS or glibc2.7+, recent fBSD etc
    if ($type =~ /sha-?512/i) {
      croak "SHA hash requested but no SHA support available" 
        unless have_sha(512);
      # SHA has variable length salts (max 16)
      # Drepper claims this can slow down attacks.
      # ...I'm under-convinced, but there you are:
      $salt .= $chrs[rand @chrs] for 1 .. rand 8;
      $salt = '$6$'.$salt.'$';
      last TYPE
    }
    
    if ($type =~ /sha(-?256)?/i) {
      croak "SHA hash requested but no SHA support available" 
        unless have_sha(256);
      $salt .= $chrs[rand @chrs] for 1 .. rand 8;
      $salt = '$5$'.$salt.'$';
      last TYPE
    }
    
    if ($type =~ /^md5$/i) {
      $salt = '$1$'.$salt.'$';
      last TYPE
    }

    croak "Unknown type specified: $type"
  }

  return Crypt::Passwd::XS::crypt($pwd, $salt)
    if have_passwd_xs();

  return crypt($pwd, $salt)
}

sub passwdcmp {
  my ($pwd, $crypt) = @_;
  return unless defined $pwd and $crypt;
  
  if ($crypt =~ /^\$2a\$\d{2}\$/) {
    ## Looks like bcrypt.
    return $crypt if $crypt eq bcrypt($pwd, $crypt)
  } else {
    if ( have_passwd_xs() ) {
      return $crypt
        if $crypt eq Crypt::Passwd::XS::crypt($pwd, $crypt)
    } else {
      return $crypt
        if $crypt eq crypt($pwd, $crypt)
    }
  }

  return
}

sub have_sha {
  ## if we have Crypt::Passwd::XS, just use that:
  return 1 if have_passwd_xs();

  my ($rate) = @_;
  $rate = 512 unless $rate;
  ## determine (the slow way) if SHA256/512 are available
  ## requires glibc2.7+ or Crypt::Passwd::XS
  my %tests = (
    256 => sub {
      my $testcrypt = crypt('a', '$5$abc$');
      return unless index($testcrypt, '$5$abc$') == 0;
      return 1
    },
  
    512 => sub {
      my $testcrypt = crypt('b', '$6$abc$');
      return unless index($testcrypt, '$6$abc$') == 0;
      return 1
    },
  );
  
  return unless defined $tests{$rate} and $tests{$rate}->();
  return 1
}

1;
__END__

=pod

=head1 NAME

App::bmkpasswd - bcrypt-capable mkpasswd(1) and exported helpers

=head1 SYNOPSIS

  bmkpasswd --help
  
  ## Generate bcrypted passwords
  ## Defaults to work cost factor '08':
  bmkpasswd
  bmkpasswd --workcost='06'

  ## Use other methods:
  bmkpasswd --method='md5'
  # SHA requires Crypt::Passwd::XS or glibc2.7+
  bmkpasswd --method='sha512'
  
  ## Compare a hash:
  bmkpasswd --check=HASH

  ## Check hash generation times:
  bmkpasswd --benchmark

=head1 DESCRIPTION

B<App::bmkpasswd> is a simple bcrypt-enabled mkpasswd. (Helper functions 
are also exported for use in other applications; see L</EXPORTED>.)

See C<bmkpasswd --help> for usage information.

Uses L<Crypt::Eksblowfish::Bcrypt> for bcrypted passwords. Bcrypt hashes 
come with a configurable work-cost factor; that allows hash generation 
to become configurably slower as computers get faster, thereby 
impeding brute-force hash generation attempts.

See L<http://codahale.com/how-to-safely-store-a-password/> for more 
on why you ought to be using bcrypt or similar "adaptive" techniques.

B<SHA-256> and B<SHA-512> are supported if available. You'll need 
either L<Crypt::Passwd::XS> or a system crypt() that can handle SHA, 
such as glibc-2.7+ or newer FreeBSD builds.

B<MD5> support is fairly universal, but it is known insecure and there 
is really no valid excuse to be using it; it is included here for 
compatibility with ancient hashes.

Salts are randomly generated.

=head1 EXPORTED

You can use the exported B<mkpasswd> and B<passwdcmp> functions in 
other Perl modules/applications:

  use App::bmkpasswd qw/mkpasswd passwdcmp/;

  ## Generate a bcrypted passwd with work-cost 08:
  $bcrypted = mkpasswd($passwd);

  ## Generate a bcrypted passwd with other work-cost:
  $bcrypted = mkpasswd($passwd, 'bcrypt', '06');

  ## SHA:
  $crypted = mkpasswd($passwd, 'sha256');
  $crypted = mkpasswd($passwd, 'sha512');

  ## Compare a password against a hash
  ## passwdcmp() will return the hash if it is a match
  if ( passwdcmp($passwd, $hash) ) {
    ## Successful match
  } else {
    ## Failed match
  }

=head1 BUGS

There is currently no easy way to pass your own salt; frankly, 
this thing is aimed at some projects of mine where that issue is 
unlikely to come up and randomized is appropriate. If that's a problem, 
patches welcome? ;-)

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut
