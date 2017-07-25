use strict;
use warnings;
use Test::More;
use App::Prove::Plugin::ShareDirDist;
use File::Spec;

@INC = map { File::Spec->rel2abs($_) } @INC;
delete $ENV{PERL5OPT};

chdir 'corpus/plugin/Foo-Bar-Baz';

App::Prove::Plugin::ShareDirDist->load;

ok $ENV{PERL5OPT}, 'PERL5OPT is set';
note "PERL5OPT = $ENV{PERL5OPT}";

like $ENV{PERL5OPT}, qr/-MFile::ShareDir::Dist=-Foo-Bar-Baz=share/;

done_testing
