# NAME

GS1::SyntaxEngine::FFI - Provides a FFI wrapper for libgs1encoders

# VERSION

version 0.2

# SYNOPSIS

    use GS1::SyntaxEngine::FFI::GS1Encoder;
    my $encoder = GS1::SyntaxEngine::FFI::GS1Encoder->new();

    # Set tha data string to a GS1 DataMatrix barcode
    # The original FNC1 char needs to be replaced by ^
    $encoder->data_str('^01070356200521631523080710230710');

    print $encoder->ai_data_str();
    # will print (01)07035620052163(15)230807(10)230711

# AUTHOR

hangy

# COPYRIGHT AND LICENSE

This software is copyright (c) 2023 by hangy.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
