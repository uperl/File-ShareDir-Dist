package File::ShareDir::Dist;

use strict;
use warnings;
use 5.008001;
use base qw( Exporter );

our @EXPORT_OK = qw( dist_share );

# ABSTRACT: Locate per-dist shared files
# VERSION

=head1 SYNOPSIS

 use File::ShareDir::Dist qw( dist_share );
 
 my $dir = dist_share 'Foo-Bar-Baz';

=head1 DESCRIPTION

L<File::ShareDir::Dist> finds share directories for a specific distribution.  It is similar
to L<File::ShareDir> with a few differences:

=over 4

=item Only supports distribution directories.

It doesn't support perl modules or perl class directories.  I have never really needed anything
other than a per-dist share directory.

=item Doesn't compute filenames.

Doesn't compute files in the share directory for you.  This is what L<File::Spec> or L<Path::Tiny>
are for.

=item Doesn't support old style shares.

For some reason there are two types.  I have never seen or needed the older type.

=item Hopefully doesn't find the wrong directory.

It doesn't blindly go finding the first share directory in @INC that matches the dist name.  It actually
checks to see that it matches the .pm file that goes along with it.

=item No non-core dependencies.

L<File::ShareDir> only has L<Class::Inspector>, but since we are only doing per-dist share
directories we don't even need that.

=item Works in your development tree

Uses the huristic, for determining if you are in a development tree, and if so, uses the common
convention to find the directory named C<share>.  If you are using a relative path in C<@INC>,
if the directory C<share> is a sibling of that relative entry in C<@INC> and if the last element
in that relative path is C<lib>.

Example, if you have the directory structure:

 lib/Foo/Bar/Baz.pm
 share/data

and you invoke perl with

 % perl -Ilib -MFoo::Bar::Baz -MFile::ShareDir::Dist=dist_share -E 'say dist_share("Foo-Bar-Baz")'

C<dist_share> will return the (absolute) path to ./share/data.  If you invoked it with:

 % export PERL5LIB `pwd`/lib
 perl -MFoo::Bar::Baz -MFile::ShareDir::Dist=dist_share -E 'say dist_share("Foo-Bar-Baz")'

it would not.  For me this covers most of my needs when developing a Perl module with a share
directory.

=back

=head1 FUNCTIONS

=head2 dist_share

 my $dir = dist_share $dist_name;

Returns the absolute path to the share directory of the given distribution.

=cut

# TODO: Built in override
# TODO: Works with PAR

sub dist_share ($)
{
  my($dist_name) = @_;
  
  my @pm = split /-/, $dist_name;
  $pm[-1] .= ".pm";

  foreach my $inc (@INC)
  {
    my $pm = File::Spec->catfile( $inc, @pm );
    if(-f $pm)
    {
      my $share = File::Spec->catdir( $inc, qw( auto share dist ), $dist_name );
      if(-d $share)
      {
        return File::Spec->rel2abs($share);
      }
      
      if(!File::Spec->file_name_is_absolute($inc))
      {
        my($v,$dir) = File::Spec->splitpath( File::Spec->rel2abs($inc), 1 );
        my @dirs = File::Spec->splitdir($dir);
        if(defined $dirs[-1] && $dirs[-1] eq 'lib')
        {
          pop @dirs; # pop off the 'lib';
          # put humpty dumpty back together again
          my $share = File::Spec->catdir(
            File::Spec->catpath($v,
              File::Spec->catdir(@dirs)
            ),
            'share',
          );
          
          if(-d $share)
          {
            return $share;
          }
        }
      }

      last;
    }
  }
  
  return;
}

1;

=head1 SEE ALSO

=over

=item L<File::ShareDir>

=back

=cut
