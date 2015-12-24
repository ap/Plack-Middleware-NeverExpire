requires 'perl', '5.008001';
requires 'strict';
requires 'warnings';
requires 'parent';
requires 'Time::Piece';
requires 'Time::Seconds';

requires 'Plack', '0.9942';
requires 'Plack::Middleware';
requires 'Plack::Util';

on test => sub {
	requires 'HTTP::Request::Common';
	requires 'Plack::Builder';
	requires 'Plack::Test';
	requires 'Test::More';
};

# vim: ft=perl
