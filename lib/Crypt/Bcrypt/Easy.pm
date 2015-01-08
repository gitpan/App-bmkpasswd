package Crypt::Bcrypt::Easy;
$Crypt::Bcrypt::Easy::VERSION = '2.005003';
use Carp;
use strictures 1;
use App::bmkpasswd 'mkpasswd', 'passwdcmp';

use Scalar::Util 'blessed';

use parent 'Exporter::Tiny';
our @EXPORT = 'bcrypt';
sub bcrypt {  Crypt::Bcrypt::Easy->new(@_)  }

=pod

=for Pod::Coverage new

=cut

sub new {
  my ($cls, %params) = @_;
  my $cost = $params{cost} || '08';
  bless \$cost, blessed($cls) || $cls
}

sub cost { ${ $_[0] } }

sub compare {
  my ($self, %params) = @_;

  unless (defined $params{text} && defined $params{crypt}) {
    confess "Expected 'text =>' and 'crypt =>' params"
  }

  passwdcmp $params{text} => $params{crypt}
}

sub crypt {
  my $self = shift;

  my %params;

  if (@_ == 1) {
    $params{text} = $_[0]
  } elsif (@_ > 1) {
    %params = @_;
    confess "Expected 'text =>' param"
      unless defined $params{text};
  } else {
    confess 'Not enough arguments; expected a password'
  }

  mkpasswd $params{text} => 
    ($params{type}   || 'bcrypt'), 
    ($params{cost}   || $self->cost), 
    ($params{strong} || () )
}

1;

=pod

=head1 NAME

Crypt::Bcrypt::Easy - Simple interface to bcrypted passwords

=head1 SYNOPSIS

  use Crypt::Bcrypt::Easy;

  # Generate bcrypted passwords:
  my $plain = 'my_password';
  my $passwd = bcrypt->crypt( $plain );

  # Generate passwords with non-default options:
  my $passwd = bcrypt->crypt( text => $plain, cost => 8 );

  # Compare passwords:
  if (bcrypt->compare( text => $plain, crypt => $passwd )) {
    # Successful match
  }

  # Generate passwords using a different default workcost:
  my $bc = bcrypt( cost => 10 );
  my $crypted = $bc->crypt( $plain );

=head1 DESCRIPTION

This module provides an easy interface to creating and comparing bcrypt-hashed
passwords via L<App::bmkpasswd>'s exported helpers (which were created to
power L<bmkpasswd> and are a bit awkward to use directly).

This POD briefly covers usage of this interface; see L<App::bmkpasswd> for
more details on bcrypt, internals, and documentation regarding the more
flexible functional interface.

This module uses L<Exporter::Tiny>; you can rename the L</bcrypt> function
as-needed:

  use Crypt::Bcrypt::Easy 'bcrypt' => { -as => 'bc' };

=head2 bcrypt

  my $bcrypt = bcrypt( cost => '10' );

Creates and returns a new Crypt::Bcrypt::Easy object.

The default workcost is '08'. This can be also be tuned for individual runs;
see L</crypt>.

(This is merely a convenience function for calling C<<
Crypt::Bcrypt::Easy->new >>.)

=head3 crypt

Create and return a new password hash:

  my $crypted = bcrypt->crypt( 'my_password' );

Override default options (see L<App::bmkpasswd>):

  my $crypted = bcrypt->crypt(
    text   => 'my_password',
    cost   => 10,
    strong => 1,
  );

Specifying a boolean true 'strong =>' parameter enables strongly-random salts
(see L<App::bmkpasswd>).

=head3 compare

  if (bcrypt->compare(text => 'my_password', crypt => $crypted)) {
     ...
  }

Returns boolean true if hashes match. Accepts any type of hash supported by
L<App::bmkpasswd> and your system; see L<App::bmkpasswd/passwdcmp>.

=head3 cost

Returns the current work-cost value; see L<App::bmkpasswd>.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut
