package ngxredis::Helper;

# (C) Maxim Dounin

# Daemon run helpers extracted from nginx tests.

###############################################################################

use warnings;
use strict;

use base qw/ Exporter /;

our @EXPORT = qw/ log_in log_out /;

###############################################################################

use File::Temp qw/ tempdir /;
use IO::Socket;
use Socket qw/ CRLF /;
use Test::More qw//;

###############################################################################

sub new {
	my $self = {};
	bless $self;

	$self->{_testdir} = tempdir(
		'nginx-test-XXXXXXXXXX',
		TMPDIR => 1,
		CLEANUP => not $ENV{TEST_NGINX_LEAVE}
	)
		or die "Can't create temp directory: $!\n";

	return $self;
}

sub DESTROY {
	my ($self) = @_;
	$self->stop_daemons();
	if ($ENV{TEST_NGINX_CATLOG}) {
		system("cat $self->{_testdir}/error.log");
	}
}

sub has_daemon($) {
	my ($self, $daemon) = @_;

	Test::More::plan(skip_all => "$daemon not found")
		unless `which $daemon`;

	return $self;
}

sub waitforfile($) {
	my ($self, $file) = @_;

	# wait for file to appear

	for (1 .. 30) {
		return 1 if -e $file;
		select undef, undef, undef, 0.1;
	}

	return undef;
}

sub waitforsocket($) {
	my ($self, $peer) = @_;

	# wait for socket to accept connections

	for (1 .. 30) {
		my $s = IO::Socket::INET->new(
			Proto => 'tcp',
			PeerAddr => $peer
		);

		return 1 if defined $s;

		select undef, undef, undef, 0.1;
	}

	return undef;
}

sub stop_daemons() {
	my ($self) = @_;

	while ($self->{_daemons} && scalar @{$self->{_daemons}}) {
		my $p = shift @{$self->{_daemons}};
		kill 'TERM', $p;
		wait;
	}

	return $self;
}

sub write_file($$) {
	my ($self, $name, $content) = @_;

	open F, '>' . $self->{_testdir} . '/' . $name
		or die "Can't create $name: $!";
	print F $content;
	close F;

	return $self;
}

sub run_daemon($;@) {
	my ($self, $code, @args) = @_;

	my $pid = fork();
	die "Can't fork daemon: $!\n" unless defined $pid;

	if ($pid == 0) {
		if (ref($code) eq 'CODE') {
			$code->(@args);
			exit 0;
		} else {
			exec($code, @args);
		}
	}

	$self->{_daemons} = [] unless defined $self->{_daemons};
	push @{$self->{_daemons}}, $pid;

	return $self;
}

sub testdir() {
	my ($self) = @_;
	return $self->{_testdir};
}
