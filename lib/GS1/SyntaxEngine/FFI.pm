# ABSTRACT: Provides a FFI wrapper for libgs1encoders

package GS1::SyntaxEngine::FFI;

use utf8;

use Moo;
use strictures 2;
use namespace::clean;

use FFI::Platypus 2.00;
use FFI::CheckLib 0.06;

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
  #[getHRI => ['gs1_encoder','char***'] => 'string'],
  #[getHRIsize => ['void'] => 'size_t'],
  #[copyHRI => ['gs1_encoder','void*','size_t'] => 'void'],
  #[getDLignoredQueryParams => ['gs1_encoder','char***'] => 'int'],
  #[getDLignoredQueryParamsSize => ['gs1_encoder'] => 'size_t'],
  #[copyDLignoredQueryParams => ['gs1_encoder','void*','size_t'] => 'void'],
  [free => ['gs1_encoder'] => 'void']
];

my $ffi = FFI::Platypus->new( api => 2 );
$ffi->find_lib( lib => 'gs1encoders' );

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

sub ai_data_str {
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setAIdataStr($self->_encoder, $value);
  }

  return _getAIdataStr($self->_encoder);
}

sub data_str {
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setDataStr($self->_encoder, $value);
  }

  return _getDataStr($self->_encoder);
}

sub scan_data {
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setScanData($self->_encoder, $value);
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
    return _setAddCheckDigit($self->_encoder, $value);
  }

  return _getAddCheckDigit($self->_encoder);
}

sub permit_unknown_ais {
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setPermitUnknownAIs($self->_encoder, $value);
  }

  return _getPermitUnknownAIs($self->_encoder);
}

sub permit_zero_suppressed_gtin_in_dl_uris{
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setPermitZeroSuppressedGTINinDLuris($self->_encoder, $value);
  }

  return _getPermitZeroSuppressedGTINinDLuris($self->_encoder);
}

sub include_data_titles_in_hri {
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setIncludeDataTitlesInHRI($self->_encoder, $value);
  }

  return _getIncludeDataTitlesInHRI($self->_encoder);
}

sub validate_ai_associations {
  my ($self, $value) = @_;
  if (@_ == 2) {
    return _setValidateAIassociations($self->_encoder, $value);
  }

  return _getValidateAIassociations($self->_encoder);
}

sub version {
  my ($self) = @_;
  return _getVersion($self->_encoder);
}

sub dl_uri {
  my ($self) = @_;
  return _getDLuri($self->_encoder);
}

sub BUILD {
  my ($self, $args) = @_;
  $self->_encoder(_init());
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