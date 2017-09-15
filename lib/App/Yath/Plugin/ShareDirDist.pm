package App::Yath::Plugin::ShareDirDist;

use strict;
use warnings;
use File::Spec;
use File::Basename qw( basename );

# ABSTRACT: A prove plugin that works with File::ShareDir::Dist
# VERSION

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
