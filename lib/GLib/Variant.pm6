use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Raw::Variant;

use GLib::VariantType;

use GLib::Roles::Implementor;

class GLib::Variant {
  also does Positional;
  also does GLib::Roles::Implementor;

  has GVariant $!v is implementor handles<p>;

  submethod BUILD (:$variant) {
    $!v = $variant;
  }

  submethod DESTROY {
    self.downref;
  }

  method GLib::Raw::Structs::GVariant
    is also<GVariant>
  { $!v }

  multi method new (GVariant $variant, :$ref = True) {
    my $o = self.bless( :$variant );
    $o.upref if $ref;
    $o;
  }

  multi method new (
    Int() $bool,
         :bool(:$boolean) is required
  )
    is static
  {
    self.new_boolean($bool);
  }
  method new_boolean(
    Int() $bool
  )
    is static
    is also<new-boolean>
  {
    my gboolean $b = $bool;
    my $v = g_variant_new_boolean($b);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int() $byte_val,
         :$byte      is required
  )
    is static
  {
    self.new_byte($byte_val);
  }
  method new_byte(
    Int() $byte
  )
    is static
    is also<new-byte>
  {
    my uint8 $b = $byte;
    my $v = g_variant_new_byte($b);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Str()  $bytestring_val,
          :$bytestring is required
  )
    is static
  {
    self.new_bytestring($bytestring_val);
  }
  method new_bytestring(
    Str() $bytestring
  )
    is static
    is also<new-bytestring>
  {
    my $v = g_variant_new_bytestring($bytestring);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    GVariant() $key,
    GVariant() $value,
               :entry(:dict_entry(:$dict-entry)) is required
  )
    is static
  {
    self.new_dict_entry($key, $value);
  }
  method new_dict_entry (
    GVariant() $key,
    GVariant() $value
  )
    is static
    is also<new-dict-entry>
  {
    my $v = g_variant_new_dict_entry($key, $value);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Num()  $double_val,
          :$double      is required
  )
    is static
  {
    self.new_double($double_val);
  }
  method new_double (
    Num() $double
  )
    is static
    is also<new-double>
  {
    my gdouble $d = $double;
    my         $v = g_variant_new_double($d);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    GVariantType()  $element_type,
    Pointer         $elements,
    Int()           $n_elements,
    Int()           $element_size,
                   :fixed_array(:fixed-array(:$array)) is required
  )
    is static
  {
    self.new_fixed_array($element_type, $elements, $n_elements, $element_size);
  }
  method new_fixed_array (
    GVariantType() $element_type,
    Pointer        $elements,
    Int()          $n_elements,
    Int()          $element_size
  )
    is static
    is also<new-fixed-array>
  {
    my uint64 ($ne, $es) = ($n_elements, $element_size);

    my $v = g_variant_new_fixed_array(
      $element_type,
      $elements,
      $ne,
      $es
    );

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    GVariantType()  $type,
    GBytes          $bytes_val,
    Int()           $trusted,
                   :$bytes      is required
  ) {
    self.new_from_bytes($type, $bytes_val, $trusted);
  }
  method new_from_bytes (
    GVariantType() $type,
    GBytes()       $bytes,
    Int()          $trusted = False
  )
    is static
    is also<new-from-bytes>
  {
    my gboolean $t = $trusted;
    my          $v = g_variant_new_from_bytes($type, $bytes, $t);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    GVariantType()  $type,
    gconstpointer   $data_val,
    Int()           $size,
    Int()           $trusted,
    GDestroyNotify  $notify     = Pointer,
    gpointer        $user_data  = Pointer,
                   :$data                   is required
  )
    is static
  {
    self.new_from_data($type, $data_val, $size, $trusted, $notify, $user_data);
  }
  method new_from_data (
    GVariantType() $type,
    gconstpointer  $data,
    Int()          $size,
    Int()          $trusted,
    GDestroyNotify $notify    = Pointer,
    gpointer       $user_data = Pointer
  )
    is static
    is also<new-from-data>
  {
    my uint64   $s = $size;
    my gboolean $t = $trusted;
    my $v = g_variant_new_from_data(
      $type,
      $data,
      $s,
      $t,
      $notify,
      $user_data
    );

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int()  $handle_int,
          :$handle      is required
  )
    is static
  {
    self.new_handle($handle_int);
  }
  method new_handle(
    Int() $handle
  )
    is static
    is also<new-handle>
  {
    my gint $h = $handle;
    my      $v = g_variant_new_handle($h);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int()  $value,
          :$int16 is required
  )
    is static
  {
    self.new_int16($value);
  }
  method new_int16 (
    Int() $value
  )
    is static
    is also<new-int16>
  {
    my int16 $val = $value;
    my         $v = g_variant_new_int16($val);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int()  $value,
          :$int32 is required
  )
    is static
  {
    self.new_int32($value);
  }
  method new_int32 (
    Int() $value
  )
    is static
    is also<new-int32>
  {
    my int32 $val = $value;
    my         $v = g_variant_new_int32($val);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int()  $value,
          :$int64 is required
  )
    is static
  {
    self.new_int64($value);
  }
  method new_int64 (
    Int() $value
  )
    is static
    is also<new-int64>
  {
    my int64 $val = $value;
    my         $v = g_variant_new_int64($val);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    GVariantType()  $type,
    GVariant()      $child,
                   :$maybe is required
  )
    is static
  {
    self.new_maybe($type, $child);
  }
  method new_maybe (
    GVariantType() $type,
    GVariant()     $child
  )
    is static
    is also<new-maybe>
  {
    my $v = g_variant_new_maybe($type, $child);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Str()  $value,
          :object_path(:object-path(:obj_path(:obj-path(:$path)))) is required
  )
    is static
  {
    self.new_object_path($value);
  }
  method new_object_path (
    Str() $value
  )
    is static
    is also<new-object-path>
  {
    my $v = g_variant_new_object_path($value);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  # method new_parsed_va (va_list $app) {
  #   g_variant_new_parsed_va($!v, $app);
  # }

  multi method new (
    Str()  $value,
          :$signature is required
  )
    is static
  {
    self.new_signature($value);
  }
  method new_signature (
    Str() $value
  )
    is static
    is also<new-signature>
  {
    my $v = g_variant_new_signature($value);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Str()  $value,
          :$string is required
  )
    is static
  {
    self.new_string($value);
  }
  method new_string (
    Str() $value
  )
    is static
    is also<new-string>
  {
    my $v = g_variant_new_string($value);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  # Do not know how this will function when GLib::Memory.free is called on
  # $value
  #
  # method new_take_string (
  #   GLib::Variant:U:
  #   Str() $value
  # ) {
  #   g_variant_new_take_string($!v);
  # }

  multi method new (
    Int()  $value,
          :$uint16 is required
  )
    is static
  {
    self.new_uint16($value);
  }
  method new_uint16 (
    Int() $value
  )
    is static
    is also<new-uint16>
  {
    my uint16 $val = $value;
    my          $v = g_variant_new_uint16($val);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int()  $value,
          :$uint32 is required
  )
    is static
  {
    self.new_uint32($value);
  }
  method new_uint32 (
    Int() $value
  )
    is static
    is also<new-uint32>
  {
    my uint32 $val = $value;
    my          $v = g_variant_new_uint32($val);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method new (
    Int()  $value,
          :$uint64 is required
  )
    is static
  {
    self.new_uint64($value);
  }
  method new_uint64 (
    Int() $value
  )
    is static
    is also<new-uint64>
  {
    my uint64 $val = $value;
    my          $v = g_variant_new_uint64($val);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  # method new_va (Str() $endptr, va_list $app) {
  #   g_variant_new_va($!v, $endptr, $app);
  # }

  multi method new (
    GVariant() $value,
              :$variant is required
  )
    is static
  {
    self.new_variant($value);
  }
  method new_variant (
    GVariant() $value
  )
    is static
    is also<new-variant>
  {
    my $v = g_variant_new_variant($value);

    $v ?? self.bless( variant => $v ) !! Nil;
  }

  multi method parse (
    GLib::Variant:U:

    Str()  $text,
          :$all = False,
          :$raw = False
  ) {
    samewith(GVariantType, $text, Str, $, :$all);
  }
  multi method parse (
    GLib::Variant:U:

    Str()                    $type,
    Str()                    $text,
    Str()                    $limit = Str,
    CArray[Pointer[GError]]  $error = gerror,
                            :$all   = False,
                            :$raw   = False;
  ) {
    samewith(
       GLib::VariantType.check($type),
       $text,
       $limit,
       $,
       $error,
      :$all,
      :$raw
    );
  }
  multi method parse (
    GLib::Variant:U:

    GVariantType()           $type,
    Str()                    $text,
    Str()                    $limit,
                             $endptr is rw,
    CArray[Pointer[GError]]  $error         = gerror,
                            :$all           = False,
                            :$raw           = False
  ) {
    my $ep = CArray[Str].new;
    $ep[0] = Str;

    # my $pt = CArray[uint8].new( $text.encode );
    # $pt[$text.chars] = 0;

    my $t = $text ?? CArray[uint8].new( $text.encode )
                  !! CArray[uint8].new;;
    $t[ ($text // '' ).chars ] = 0;

    my $pl = $limit ?? CArray[uint8].new( $limit.encode )
                    !! CArray[uint8].new;;
    $pl[ ($limit // '').chars ] = 0;

    clear_error;
    # try using explicitly-manage on $text?
    my $v = g_variant_parse(
      $type // GVariantType,
      $t,
      $pl,
      $ep,
      $error
    );
    set_error($error);

    # cw: -XXX- Raku will always try to decode as UTF8 if using ppr()
    #     ...please circle back!
    $endptr = $ep;

    my $retVal = $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;

    $all.not ?? $retVal !! ($retVal, $endptr);
  }

  method byteswap {
    g_variant_byteswap($!v);
  }

  method check_format_string (Str() $format_string, Int() $copy_only)
    is also<check-format-string>
  {
    my gboolean $co = $copy_only;

    g_variant_check_format_string($!v, $format_string, $co);
  }

  # Uses GVariantClass, so not in-scope.
  # method classify {
  #   g_variant_classify($!v);
  # }

  method compare (GVariant() $two) {
    g_variant_compare($!v, $two);
  }

  method dup_bytestring is also<dup-bytestring> {
    my uint64 $l = 0;

    g_variant_dup_bytestring($!v, $l);
  }

  method dup_bytestring_array (:$raw = False) is also<dup-bytestring-array> {
    my uint64 $l = 0;

    my $sa = g_variant_dup_bytestring_array($!v, $l);
    $raw ?? $sa !! CStringArrayToArray($sa);
  }

  method dup_objv (:$raw = False) is also<dup-objv> {
    my uint64 $l = 0;
    my $sa = g_variant_dup_objv($!v, $l);

    $raw ?? $sa !! CStringArrayToArray($sa);
  }

  method dup_string is also<dup-string> {
    my uint64 $l = 0;

    g_variant_dup_string($!v, $l);
  }

  method dup_strv (:$raw = False) is also<dup-strv>  {
    my uint64 $l = 0;

    my $sa = g_variant_dup_strv($!v, $l);
    $raw ?? $sa !! CStringArrayToArray($sa);
  }

  method equal (GVariant() $two) {
    g_variant_equal($!v, $two);
  }

  method get_boolean
    is also<
      get-boolean
      boolean
    >
  {
    so g_variant_get_boolean($!v);
  }

  method get_byte
    is also<
      get-byte
      byte
    >
  {
    g_variant_get_byte($!v);
  }

  method get_bytestring
    is also<
      get-bytestring
      bytestring
    >
  {
    g_variant_get_bytestring($!v);
  }

  method get_bytestring_array (:$raw = False)
    is also<
      get-bytestring-array
      bytestring_array
      bytestring-array
    >
  {
    my gsize $l = 0;
    my $sa = g_variant_get_bytestring_array($!v, $l);

    $raw ?? $sa !! CStringArrayToArray($sa)
  }

  method get_child_value (Int() $index, :$raw = False)
    is also<get-child-value>
  {
    my gsize $i = $index;

    propReturnObject(
      g_variant_get_child_value($!v, $i),
      $raw,
      |self.getChildValue
    );
  }

  method get_data
    is also<
      get-data
      data
    >
  {
    g_variant_get_data($!v);
  }

  method get_data_as_bytes
    is also<
      get-data-as-bytes
      data_as_bytes
      data-as-bytes
    >
  {
    g_variant_get_data_as_bytes($!v);
  }

  method get_double
    is also<
      get-double
      double
    >
  {
    g_variant_get_double($!v);
  }

  method get_fixed_array (Int() $n_elements, Int() $element_size)
    is also<get-fixed-array>
  {
    my uint64 ($ne, $es) = ($n_elements, $element_size);

    g_variant_get_fixed_array($!v, $ne, $es);
  }

  method get_handle
    is also<
      get-handle
      handle
    >
  {
    g_variant_get_handle($!v);
  }

  method get_int16
    is also<
      get-int16
      int16
    >
  {
    g_variant_get_int16($!v);
  }

  method get_int32
    is also<
      get-int32
      int32
    >
  {
    g_variant_get_int32($!v);
  }

  method get_int64
    is also<
      get-int64
      int64
    >
  {
    g_variant_get_int64($!v);
  }

  method get_maybe ( :$raw = False )
    is also<
      get-maybe
      maybe
    >
  {
    propReturnObject(
      g_variant_get_maybe($!v),
      $raw,
      |self.getTypePair
    );
  }

  method get_normal_form
    is also<
      get-normal-form
      normal_form
      normal-form
    >
  {
    g_variant_get_normal_form($!v);
  }

  method get_objv (:$raw = False)
    is also<
      get-objv
      objv
    >
  {
    my gsize $l = 0;
    my $sa = g_variant_get_objv($!v, $l);

    $raw ?? $sa !! CStringArrayToArray($sa, $l);
  }

  method get_size
    is also<
      get-size
      size
    >
  {
    g_variant_get_size($!v);
  }

  method get_string (:$all = False)
    is also<
      get-string
      string
    >
  {
    my uint64 $l = 0;

    my $str = g_variant_get_string($!v, $l);
    $all.not ?? $str !! ($str, $l);
  }

  method get_strv (:$raw = False)
    is also<
      get-strv
      strv
    >
  {
    my uint64 $l = 0;
    my $sa = g_variant_get_strv($!v, $l);

    $raw ?? $sa !! CStringArrayToArray($sa, $l);
  }


  method get_variant_type
    is also<
      get_vtype
      get-vtype
      variant-type
      variant_type
      vtype
    >
  {
    g_variant_get_type($!v);
  }

  method get_type_string
    is also<
      get-type-string
      type_string
      type-string
    >
  {
    g_variant_get_type_string($!v);
  }

  method get_uint16
    is also<
      get-uint16
      uint16
    >
  {
    g_variant_get_uint16($!v);
  }

  method get_uint32
    is also<
      get-uint32
      uint32
    >
  {
    g_variant_get_uint32($!v);
  }

  method get_uint64
    is also<
      get-uint64
      uint64
    >
  {
    g_variant_get_uint64($!v);
  }

  # method get_va (Str() $format_string, Str() $endptr, va_list $app) {
  #   g_variant_get_va($!v, $format_string, $endptr, $app);
  # }

  method get_variant (:$raw = False)
    is also<
      get-variant
      variant
    >
  {
    my $v = g_variant_get_variant($!v);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;
  }

  method getObjPath {
    my $s = self.get_string;

    warn "'$s' is not a valid object path!" unless $s ~~ / ^ \w+ % '/' $ /;
    return $s;
  }

  method Hash ( :$raw = False, :$variant = False ) {
    my $i = GVariantIter.new;
    my $t = self.get_type_string;

    die "'{ $t }' is not Hash compatible!"
      unless $t ~~ /^ 'a' $<subtype>=[ '{s' (\w) '}' ] $/;

    my ($subtype, $vt) = ($/<subtype>.Str, $vt.Str);

    my $typename =
    my \valueType = do given $vt {
      when 'v'       { $typename = 'gvariant'; Pointer[GVariant] }
      when 'b'       { $typename = 'uint32'  ; CArray[uint32]    }
      when 'y'       { $typename = 'uint8'   ; CArray[uint8]     }
      when 'n'       { $typename = 'int16'   ; CArray[int16]     }
      when 'q'       { $typename = 'uint16'  ; CArray[uint16]    }
      when 'i' | 'h' { $typename = 'int32'   ; CArray[int32]     }
      when 'u'       { $typename = 'uint32'  ; CArray[uint32]    }
      when 'x'       { $typename = 'int64'   ; CArray[int64]     }
      when 't'       { $typename = 'uint64'  ; CArray[uint64]    }
      when 'd'       { $typename = 'num64'   ; CArray[num64]     }
      when 's' | 'g' { $typename = 'Str'     ; Str               }

      default {
        die "Unknown value type '{ $_ }'";
      }
    }

    my ($k, $v, %h) = ( newCArray(Str), newCArray(valueType) );

    g_variant_iter_init($i, self.GVariant);

    my &s = ::("g_variant_hash_{ $typename }_loop");
    while ( &s($i, $subtype, $k, $v) ) {
      unless $raw {
        $v = do given valueType {
          when Pointer[GVariant] {
            my $v1 = propReturnObject($v[0].deref, $raw, |self.getTypePair);
            $v1 .= getValue;
            $v1
          }

          when Str {
            $v[0];
          }

          default {
            $v[0][0]
          }
        }
      }
      %h{ $k[0] } = $v;
    }
    %h;
  }

  method getValue {
    my $t = self.get_type_string;

    # cw: Handle known patterns - a{s[a-z]} is a hash
    return self.Hash  if $t ~~ / 'a{s' \w '}' /;
    # cw: The first token set needs to use regex to pull nested expressions!
    return self.Array if $t ~~ /'a(' .+? ')' | 'a'\w | '(a' \w ')' /;

    do given $t {
      when 'm'             { my $var = self.get_maybe;   $var.getValue }
      when 'v'             { my $var = self.get_variant; $var.getValue }

      when 'b'             { self.get_boolean }
      when 'y'             { self.get_byte    }
      when 'n'             { self.get_int16   }
      when 'q'             { self.get_uint16  }
      when 'i' | 'h'       { self.get_int32   }
      when 'u'             { self.get_uint32  }
      when 'x'             { self.get_int64   }
      when 't'             { self.get_uint64  }
      when 'd'             { self.get_double  }
      when 's' | 'g'       { self.get_string  }
      when 'o'             { self.getObjPath  }

      default {
        die "'{ $_ }' is an invalid type string!"
      }
    }
  }

  multi method isList {
    samewith( self.get-type-string );
  }
  multi method isList ($t) {
    $t.starts-with: '('
    &&
    $t.ends-with: ')'
  }

  multi method isHash {
    samewith( self.get-type-string );
  }
  multi method isHash ($t) {
    so $t ~~ / ^ 'a{s' \w '}' $/;
  }

  method Array {
    return Nil unless self.elems;

    my @return;
    for ^self.elems {
      my $v = self.get_child_value($_);

      @return.push: $v.is_container ?? $v.List !! $v.getValue;
    }
  }

  method List {
    return Nil unless self.elems;

    my $t = self.get_type_string;

    die "Value is associative!" unless self.isList($t);

    $t .= substr(1, * - 1);

    my @return;
    my $k = 0;
    while $t.chars {
      my $i = 1;

      NEXT {
        $k++;
        $t .= substr($i);
      };

      my $var = self.get_child_value($k);

      # cw: This needs to be recursive.
      if $var.isList || $var.isHash {
        @return.push: $var.List if $var.isList;
        @return.push: $var.Hash if $var.isHash;
        $i = $var.get_type_string.chars;
        next;
      }

      @return.push: $var.getValue;
    }
  }

  method hash {
    g_variant_hash($!v);
  }

  method is_container is also<is-container> {
    so g_variant_is_container($!v);
  }

  method is_floating is also<is-floating> {
    so g_variant_is_floating($!v);
  }

  # Shorter aliases go in favor of the get_* form
  method is_normal_form is also<is-normal-form> {
    so g_variant_is_normal_form($!v);
  }

  method is_object_path (
    Str() $path
  )
    is static
    is also<is-object-path>
  {
    so g_variant_is_object_path($path);
  }

  method is_of_type (GVariantType() $type) is also<is-of-type> {
    so g_variant_is_of_type($!v, $type);
  }

  method is_signature (
    Str() $signature
  )
    is static
    is also<is-signature>
  {
    so g_variant_is_signature($signature);
  }

  method lookup_value (Str() $key, GVariantType() $expected_type)
    is also<lookup-value>
  {
    g_variant_lookup_value($!v, $key, $expected_type);
  }

  method n_children
    is also<
      n-children
      elems
    >
  {
    g_variant_n_children($!v);
  }

  method parse_error_print_context (
    GError() $error,
    Str()    $source_str
  )
    is static
    is also<parse-error-print-context>
  {
    g_variant_parse_error_print_context($error, $source_str);
  }

  # Singleton.
  method parse_error_quark is also<parse-error-quark> {
    g_variant_parse_error_quark();
  }

  multi method print (Bool :$annotate is required) {
    samewith($annotate)
  }
  multi method print (Int() $type_annotate = True) {
    my gboolean $t = $type_annotate;

    my $str-from-c = g_variant_print($!v, $t);
    my $s = $str-from-c.clone;

    # cw: -XXX- SEGV!
    #free( cast(Pointer, $str-from-c) );

    $s;
  }

  method print_string (GString $string, Int() $type_annotate)
    is also<print-string>
  {
    my gboolean $t = $type_annotate;

    g_variant_print_string($!v, $string, $t);
  }

  method ref is also<upref> {
    g_variant_ref($!v);
    self;
  }

  method ref_sink is also<ref-sink> {
    g_variant_ref_sink($!v);
    self;
  }

  method store (gpointer $data) {
    g_variant_store($!v, $data);
  }

  method take_ref is also<take-ref> {
    g_variant_take_ref($!v);
  }

  method unref is also<downref> {
    g_variant_unref($!v);
  }

  # Positional only applies to containers
  method AT-POS (\i) {
    X::GLib::Variant::NotAContainer.throw unless self.is_container;
    self.get_child_value(i);
  }

}

class GLib::Variant::Builder {
  has GVariantBuilder $!vb;

  submethod BUILD ( :builder(:$!vb) ) { }

  method GLib::Raw::Definitions::GVariantBuilder
    is also<GVariantBuilder>
  { $!vb }

  multi method new ($builder) {
    $builder ?? self.bless( :$builder ) !! Nil;
  }
  multi method new (GVariantType() $type) {
    my $builder = g_variant_builder_new($type);

    $builder ?? self.bless( :$builder ) !! Nil;
  }

  method unref {
    g_variant_builder_unref($!vb)
  }

  method ref {
    g_variant_builder_ref($!vb);
    self;
  }

  method init (GLib::Variant::Builder:U:
    GVariantBuilder $new-builder,
    GVariantType() $type
  ) {
    g_variant_builder_init($new-builder, $type);
  }

  method end (:$raw = False) {
    my $v = g_variant_builder_end($!vb);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  method clear {
    g_variant_builder_clear($!vb);
    self;
  }

  method open (GVariantType() $type) {
    g_variant_builder_open($!vb, $type);
    self;
  }

  method close {
    g_variant_builder_close($!vb);
    self;
  }

  method add_value (GVariant() $value) {
    g_variant_builder_add_value ($!vb, $value);
    self;
  }

  method add (Str() $spec) {
    g_variant_builder_add ($!vb, $spec, Str);
    self;
  }

  method add_parsed (Str() $spec) {
    g_variant_builder_add_parsed($!vb, $spec, Str);
    self;
  }

}
