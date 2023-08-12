use utf8;

use 5.010_000;

use strict;
use warnings;

use Test2::V0;

use GS1::SyntaxEngine::FFI;

my $encoder = GS1::SyntaxEngine::FFI->new();

my $barcode = '^01070356200521631523080710230710';
my $value_was_set = $encoder->data_str($barcode);
is($value_was_set, 1, 'Data string not set: ' . $encoder->error_msg($encoder));

my $result = $encoder->data_str;
is($result, $barcode);

my $ai = $encoder->ai_data_str();
is('(01)07035620052163(15)230807(10)230710', $ai, 'AI string not as expected');

done_testing;

1;