package Plack::Middleware::NeverExpire;
use strict;
use parent 'Plack::Middleware';

# ABSTRACT: set expiration headers far in the future

use Plack::Util ();
use Time::Piece ();
use Time::Seconds 'ONE_YEAR';

sub call {
	my $self = shift;
	my ( $env ) = @_;
	my $res = $self->app->( $env );
	if ( $res->[0] == 200 ) {
		my $date = Time::Piece->gmtime( time + ONE_YEAR );
		Plack::Util::header_set( $res->[1], 'Expires', $date->strftime );
		Plack::Util::header_push( $res->[1], 'Cache-Control', 'max-age=' . ONE_YEAR );
	}
	return $res;
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
