#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use v5.10;    # in order to use `say` safely
use Term::ANSIColor;
use IPC::Run qw(start);
use Getopt::Long;

our $red   = color('red');
our $reset = color('reset');

my $SEP;
my $n;
my $replace;
my $debug;

GetOptions(
    'delimiter=s' => \$SEP,
    'n=i'         => \$n,
    'I=s'         => \$replace,
    'Debug'           => \$debug,
);

$replace = '{}' unless defined($replace);
say STDERR qq(${red}Debug: use replace string `$replace`$reset) if $debug;

die qq(${red}n should not be 0$reset) if defined($n) && $n == 0;

my @args = ();

if ( defined($SEP) ) {
    my @lines = <STDIN>;
    $_ = join "\n", @lines;
    say STDERR qq(${red}Debug: use separator `$SEP`$reset) if $debug;
    push @args, split( $SEP, $_ );
}
else {
    say STDERR qq(${red}Debug: use default separator `\\n`$reset) if $debug;
    chomp( @args = <STDIN> );
}

my @cmd = @ARGV;
if ( @cmd == 0 ) {
    push @cmd, 'echo';
    say STDERR qq(${red}Debug: No command given, fallback to `echo`$reset)
      if $debug;
}

# NOTE:
# 1. use replace string, if exists, ignore arg number
# 2. if not replace string present, check arg number
# 3. no replace or arg number, append all parsed arguments to given command

if ( my $num = grep { $_ eq $replace } @cmd ) {
    while ( @_ = splice( @args, 0, $num ) ) {
        my @to_run = @cmd;
        @to_run = map { $_ eq $replace ? shift @_ : $_; } @to_run;
        say STDERR qq(${red}Debug: run command: `@{to_run}`$reset) if $debug;
        start( \@to_run );
    }
    wait;
}
elsif ( defined $n ) {
    while ( @_ = splice( @args, 0, $n ) ) {
        my @to_run = @cmd;
        push @to_run, @_;
        say STDERR qq(${red}Debug: run command: `@{to_run}`$reset) if $debug;
        start( \@to_run );
    }
    wait;
}
else {
    push @cmd, @args;
    say STDERR qq(${red}Debug: run command: `@{cmd}`$reset) if $debug;
    exec @cmd;
}
