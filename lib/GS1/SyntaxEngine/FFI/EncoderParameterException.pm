# SPDX-License-Identifier: GPL-1.0-or-later OR Artistic-1.0-Perl

# ABSTRACT: Error in case that libgs1encoders couldn't be initialized

package GS1::SyntaxEngine::FFI::EncoderParameterException;

use utf8;

use Moose;
with 'Throwable';

has message => (is => 'ro');

1;