use 5.008001; use strict; use warnings;

package Plack::Middleware::NeverExpire;

our $VERSION = '1.007';

BEGIN { require Plack::Middleware; our @ISA = 'Plack::Middleware' }

use Plack::Util ();
use Time::Piece ();
use Time::Seconds 'ONE_YEAR';

sub imf_fixdate { Time::Piece->gmtime( $_[0] )->strftime }

sub prepare_app { shift->{'_cached_time'} = 'NaN' }

sub call {
	my $self = shift;
	my $now = time;
	Plack::Util::response_cb( &{ $self->app }, sub {
		$_[0][0] == 200 or return;
		my $h = $_[0][1];
		push @$h, 'Cache-Control', 'max-age=' . ONE_YEAR . ', public';
		Plack::Util::header_set( $h, 'Expires' => $self->{'_cached_time'} == $now
			?   $self->{'_cached_stamp'}
			: ( $self->{'_cached_stamp'} = imf_fixdate ONE_YEAR + ( $self->{'_cached_time'} = $now ) )
		);
	} );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Plack::Middleware::NeverExpire - set expiration headers far in the future

=head1 SYNOPSIS

 # in app.psgi
 use Plack::Builder;
 
 builder {
     enable_if { $_[0]{'PATH_INFO'} =~ m!^/static/! } 'NeverExpire';
     $app;
 };

=head1 DESCRIPTION

This middleware adds headers to a response that allow proxies and browsers to
cache them for an effectively unlimited time. It is meant to be used in
conjunction with the L<Conditional|Plack::Middleware::Conditional> middleware.

=head1 SEE ALSO

=over 4

=item *

L<Plack::Middleware::Expires>

For most requests you want either immediate expiry with conditional C<GET>,
or indefinite caching, or on high-load websites maybe a very short expiry
duration for certain URIs (on the order of minutes or seconds, just to keep
them from getting hammered): fine-grained control is rarely needed. I wanted
a really trivial middleware for when it's not, so I wrote NeverExpire.

But when you need it, L<Expires|Plack::Middleware::Expires> will give you the
precise control over expiry durations that NeverExpire doesn't.

=back

=cut
