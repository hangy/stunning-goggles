# SPDX-License-Identifier: GPL-1.0-or-later OR Artistic-1.0-Perl

package GS1::SyntaxEngine::FFI;

# ABSTRACT: Provides a FFI wrapper for libgs1encoders

use utf8;

=head1 SYNOPSIS

  use GS1::SyntaxEngine::FFI::GS1Encoder;
  my $encoder = GS1::SyntaxEngine::FFI::GS1Encoder->new();

  # Set tha data string to a GS1 DataMatrix barcode
  # The original FNC1 char needs to be replaced by ^
  $encoder->data_str('^01070356200521631523080710230710');

  print $encoder->ai_data_str();
  # will print (01)07035620052163(15)230807(10)230711

=cut

1;
