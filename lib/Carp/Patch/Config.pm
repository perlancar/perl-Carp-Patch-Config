package Carp::Patch::Config;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.23 qw();
use base qw(Module::Patch);

our %config;

sub patch_data {
    return {
        v => 3,
        patches => [
        ],
        config => {
            MaxArgLen  => {schema=>'int*'},
            MaxArgNUms => {schema=>'int*'},
        },
        after_read_config => sub {
            no strict 'refs';
            for (keys %config) {
                ${"Carp::$_"} = $config{$_} if defined $config{$_};
            }
        },
   };
}

1;
# ABSTRACT: Set some Carp variables

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

 % perl -MCarp::Patch::Config=-MaxArgNums,20 -d:Confess ...


=head1 DESCRIPTION

This is not so much a "patch" for L<Carp>, but just a convenient way to set some
Carp package variables from the command-line. Currently can set these variables:
C<MaxArgLen>, C<MaxArgNums>.
