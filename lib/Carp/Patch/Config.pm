package Carp::Patch::Config;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch qw();
use base qw(Module::Patch);

my @oldvals;
our %config;

sub patch_data {
    return {
        v => 3,
        patches => [
        ],
        config => {
            -MaxArgLen  => {
                schema => 'int*',
            },
            -MaxArgNums => {
                schema => 'int*',
            },
            -Dump => {
                schema => 'bool*',
                description => <<'_',

This is not an actual configuration for Carp, but a shortcut for:

    $Carp::RefArgFormatter = sub {
        require Data::Dmp;
        Data::Dmp::dmp($_[0]);
    };

_
            },
        },
        after_patch => sub {
            no strict 'refs';
            my $oldvals = {};
            for my $name (keys %config) {
                my $carp_config_name = $name;
                my $carp_config_val  = $config{$name};
                if ($name =~ /\A-?Dump\z/) {
                    $carp_config_name = 'RefArgFormatter';
                    $carp_config_val  = $config{$name} ? sub {
                        require Data::Dmp;
                        Data::Dmp::dmp($_[0]);
                    } : undef;
                }
                $oldvals->{$carp_config_name} = ${"Carp::$carp_config_name"};
                ${"Carp::$carp_config_name"} = $carp_config_val;
            }
            push @oldvals, $oldvals;
        },
        after_unpatch => sub {
            no strict 'refs';
            my $oldvals = shift @oldvals or return;
            for (keys %$oldvals) {
                ${"Carp::$_"} = $oldvals->{$_};
            }
        },
   };
}

1;
# ABSTRACT: Set some Carp variables

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

 % perl -MCarp::Patch::Config=-MaxArgNums,20,-Dump,1 -d:Confess ...


=head1 DESCRIPTION

This is not so much a "patch" for L<Carp>, but just a convenient way to set some
Carp package variables from the command-line. Currently can set these variables:
C<MaxArgLen>, C<MaxArgNums>.


=head1 append:SEE ALSO

L<Devel::Confess>
