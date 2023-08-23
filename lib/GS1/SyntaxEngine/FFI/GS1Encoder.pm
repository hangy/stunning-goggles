# SPDX-License-Identifier: GPL-1.0-or-later OR Artistic-1.0-Perl

# ABSTRACT: Provides a FFI wrapper for libgs1encoders

package GS1::SyntaxEngine::FFI::GS1Encoder;

use utf8;

use Moo;

use strictures 2;
use namespace::clean;

use FFI::Platypus 2.08;

use Alien::libgs1encoders 0.02;

use GS1::SyntaxEngine::FFI::InitException;
use GS1::SyntaxEngine::FFI::EncoderParameterException;

my $opaque_types = [map {"gs1_$_"} qw/encoder/];

my $functions = [
  [getVersion => ['void'] => 'string'],
  [init => ['void'] => 'gs1_encoder'],
  [getErrMsg => ['gs1_encoder'] => 'string'],
  [getSym => ['gs1_encoder'] => 'int'],
  [setSym => ['gs1_encoder', 'int'] => 'bool'],
  [getAddCheckDigit => ['gs1_encoder'] => 'bool'],
  [setAddCheckDigit => ['gs1_encoder', 'bool'] => 'bool'],
  [getPermitUnknownAIs => ['gs1_encoder'] => 'bool'],
  [setPermitUnknownAIs => ['gs1_encoder', 'bool'] => 'bool'],
  [getPermitZeroSuppressedGTINinDLuris => ['gs1_encoder'] => 'bool'],
  [setPermitZeroSuppressedGTINinDLuris => ['gs1_encoder', 'bool'] => 'bool'],
  [getIncludeDataTitlesInHRI => ['gs1_encoder'] => 'bool'],
  [setIncludeDataTitlesInHRI => ['gs1_encoder', 'bool'] => 'bool'],
  [getValidateAIassociations => ['gs1_encoder'] => 'bool'],
  [setValidateAIassociations => ['gs1_encoder', 'bool'] => 'bool'],
  [getDataStr => ['gs1_encoder'] => 'string'],
  [setDataStr => ['gs1_encoder', 'string'] => 'bool'],
  [getAIdataStr => ['gs1_encoder'] => 'string'],
  [setAIdataStr => ['gs1_encoder', 'string'] => 'bool'],
  [getDLuri => ['gs1_encoder','string'] => 'string'],
  [getScanData => ['gs1_encoder'] => 'string'],
  [setScanData => ['gs1_encoder', 'string'] => 'bool'],
  [free => ['gs1_encoder'] => 'void']
];

my $ffi = FFI::Platypus->new( lib => [ Alien::libgs1encoders->dynamic_libs ] );

for my $type (@{ $opaque_types }) {
  $ffi->custom_type($type => {
    native_type => 'opaque',
    native_to_perl => sub {
      my $class = "GS1::SyntaxEngine::FFI::Types::$type";
      bless \$_[0], $class;
    },
    perl_to_native => sub {
      my $val = shift;
      die "Wrong type passed, ".ref($val)." expected GS1::SyntaxEngine::FFI::Types::$type" unless ref($val) eq "GS1::SyntaxEngine::FFI::Types::$type";

      return ${ $val }
  }});

  $ffi->type('opaque' => $type . '_ptr');
}

for my $function (@{ $functions }) {
  my $name = shift @{ $function };
  $ffi->attach(["gs1_encoder_$name" => "_$name"], @{ $function });
}

has _encoder => (
  is => 'rw',
);

sub _throw_error_exception {
  my ($self) = @_;
  GS1::SyntaxEngine::FFI::EncoderParameterException->throw({ message => $self->error_msg });
  return;
}

sub ai_data_str {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setAIdataStr($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getAIdataStr($self->_encoder);
}

sub data_str {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setDataStr($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getDataStr($self->_encoder);
}

sub scan_data {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setScanData($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getScanData($self->_encoder);
}

sub error_msg {
  my ($self) = @_;
  return _getErrMsg($self->_encoder);
}

sub add_check_digit {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setAddCheckDigit($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getAddCheckDigit($self->_encoder);
}

sub permit_unknown_ais {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setPermitUnknownAIs($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getPermitUnknownAIs($self->_encoder);
}

sub permit_zero_suppressed_gtin_in_dl_uris {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setPermitZeroSuppressedGTINinDLuris($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getPermitZeroSuppressedGTINinDLuris($self->_encoder);
}

sub include_data_titles_in_hri {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setIncludeDataTitlesInHRI($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getIncludeDataTitlesInHRI($self->_encoder);
}

sub validate_ai_associations {
  my ($self, $value) = @_;
  if (@_ == 2) {
    _setValidateAIassociations($self->_encoder, $value) or $self->_throw_error_exception();
  }

  return _getValidateAIassociations($self->_encoder);
}

sub version {
  my ($self) = @_;
  return _getVersion($self->_encoder);
}

sub dl_uri {
  my ($self, $domain) = @_;
  return _getDLuri($self->_encoder, $domain);
}

sub BUILD {
  my ($self, $args) = @_;
  my $encoder = _init();
  if (!$encoder) {
    GS1::SyntaxEngine::FFI::InitException->throw();
  }

  $self->_encoder($encoder);
  return $self;
}

sub DEMOLISH {
  my ($self, $in_global_destruction) = @_;
  my $encoder = $self->_encoder;
  if ($encoder) {
    _free($encoder);
  }

  return $self;
}

1;