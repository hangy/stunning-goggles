use utf8;

use 5.010_000;

use strict;
use warnings;

use Test2::V0;

use GS1::SyntaxEngine::FFI;

my $encoder = GS1::SyntaxEngine::FFI->new();
my $version = $encoder->version;

is($version, 'Aug 12 2023', 'Version matches');

done_testing;

1;