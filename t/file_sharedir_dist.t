use strict;
use warnings;
use overload ();
use Test::More;
use File::Spec;
use File::ShareDir::Dist qw( dist_share );

sub slurp
{
  my($filename) = @_;
  open my $fh, '<', $filename;
  my $data = do { local $/; <$fh> };
  close $fh;
  $data;
}

subtest 'simple' => sub {

  subtest 'not there' => sub {
  
    local @INC = (File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib1 ))));
    my @ret = dist_share 'Foo-Bar-Baz';
    is_deeply \@ret, [];
  
  };
  
  subtest 'there, but not there' => sub {

    local @INC = (File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib2 ))));
    my @ret = dist_share 'Foo-Bar-Baz';
    is_deeply \@ret, [];

  };
  
  subtest 'there and there' => sub {

    local @INC = (File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib3 ))));
    my @ret = dist_share 'Foo-Bar-Baz';
    is $#ret, 0, 'exactly one';
    my $dir = $ret[0];
    ok -d $dir, 'is a directory';
    
    my $file = File::Spec->catfile($dir, 'word.txt');
    ok -f $file, 'has directory';

    is slurp($file), "33\n", 'file content matches';

  };
  
  subtest 'there and there, using module name' => sub {

    local @INC = (File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib3 ))));
    my @ret = dist_share 'Foo::Bar::Baz';
    is $#ret, 0, 'exactly one';
    my $dir = $ret[0];
    ok -d $dir, 'is a directory';
    
    my $file = File::Spec->catfile($dir, 'word.txt');
    ok -f $file, 'has directory';

    is slurp($file), "33\n", 'file content matches';

  };

  subtest 'there, but not there, followed by there and there' => sub {

    local @INC = (
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib2 ))),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib3 )))
    );
    my @ret = dist_share 'Foo-Bar-Baz';
    is $#ret, 0, 'exactly one';
    my $dir = $ret[0];
    ok -d $dir, 'is a directory';
    
    my $file = File::Spec->catfile($dir, 'word.txt');
    ok -f $file, 'has directory';

    is slurp($file), "33\n", 'file content matches';


  };

};

subtest 'from dev' => sub {

  subtest 'dev without share does not find installed share' => sub {

    local @INC = (
                          File::Spec->catdir(qw( corpus dev1 lib )),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib1 ))),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib2 ))),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib3 )))
    );

    my @ret = dist_share 'Foo-Bar-Baz';
    is_deeply \@ret, [];
  
  };

  subtest 'dev with share' => sub {

    local @INC = (
                          File::Spec->catdir(qw( corpus dev2 lib )),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib1 ))),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib2 ))),
      File::Spec->rel2abs(File::Spec->catdir(qw( corpus lib3 ))),
      @INC,
    );
    
    my @ret = dist_share 'Foo-Bar-Baz';
  
    is $#ret, 0, 'exactly one';
    my $dir = $ret[0];
    ok -d $dir, 'is a directory';
    
    my $file = File::Spec->catfile($dir, 'word.txt');
    ok -f $file, 'has directory';

    is slurp($file), "d2\n", 'file content matches';
  };

};

done_testing
