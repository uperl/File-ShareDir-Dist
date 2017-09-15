package App::Yath::Plugin::ShareDirDist;

use strict;
use warnings;
use File::Spec;
use File::Basename qw( basename );

# ABSTRACT: A prove plugin that works with File::ShareDir::Dist
# VERSION

=head1 SYNOPSIS

 % yath -p ShareDirDist

=head1 DESCRIPTION

This plugin sets the override for L<File::ShareDir::Dist> based on
the current directory name, if there is a C<share> directory.  It
assumes that the directory name is the same as the dist name.  This
may not be the case, but it happens to be the convention that I use.

=head1 CAVEATS

As of this writing, L<Test2::Harness> and L<App::Yath> are still
B<experimental> and can change at any time.  Documentation is sparse.
Obviously use this plugin at your own risk.

=head1 SEE ALSO

=over 4

=item L<App::Yath>

=item L<Test2::Harness>

=back

=cut

sub options {}

sub pre_init
{
  if(-d "share")
  {
    my $dist_name = basename(File::Spec->rel2abs("."));
    $ENV{PERL_FILE_SHAREDIR_DIST} = "$dist_name=share";
  }
}

sub post_init {}
sub find_files {}
sub block_default_search {}

1;
