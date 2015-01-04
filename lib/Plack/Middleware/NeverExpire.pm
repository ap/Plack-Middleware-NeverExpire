use 5.008001;
use strict;
use warnings;

package Plack::Middleware::NeverExpire;

# ABSTRACT: set expiration headers far in the future

use parent 'Plack::Middleware';

use Plack::Util ();
use Time::Piece ();
use Time::Seconds ();

sub call {
	my $self = shift;
	Plack::Util::response_cb( $self->app->( shift ), sub {
		my $res = shift;
		return if $res->[0] != 200;
		my $date = Time::Piece->gmtime( time + Time::Seconds::ONE_YEAR );
		Plack::Util::header_set( $res->[1], 'Expires', $date->strftime );
		Plack::Util::header_push( $res->[1], 'Cache-Control', 'max-age=' . Time::Seconds::ONE_YEAR . ', public' );
		return;
	} );
}

1;

__END__

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
