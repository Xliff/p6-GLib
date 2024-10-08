use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Error;

use GLib::Roles::Implementor;
use GLib::Roles::TypedBuffer;

class GLib::Error {
  also does GLib::Roles::Implementor;

  has GError $!e is implementor handles<domain code message p>;

  submethod BUILD (:$error) {
    $!e = $error;
  }

  method GLib::Raw::Structs::GError
    is also<GError>
  { $!e }

  multi method new (GError $error) {
    self.bless( :$error );
  }
  multi method new (*@a) {
    self.bless( error => GError.new(|@a) );
  }

  method new_literal (GQuark() $domain, Int() $code, Str() $message)
    is also<new-literal>
  {
    my gint $c = $code;

    self.bless( error => g_error_new_literal($domain, $c, $message) );
  }

  method copy {
    GLib::Error.new( g_error_copy($!e) );
  }

  method free {
    g_error_free($!e);
  }

  method clear {
    my $ea = CArray[Pointer[GError]].new;
    $ea[0] = $!e.p;

    g_clear_error($ea);
  }

  # Not sure of a valid use-case for this.
  #
  # method propagate_error (GError() $src) {
  #   my $eb = GLib::Roles::TypedBuffer[GError].new( size => 1 );
  #   $ea.bind(0, GError);
  #
  #   my $ea = CArray[Pointer[GError]].new;
  #   $ea[0] = $eb.p;
  #
  #   g_propagate_error($ea, $src);
  #   $!e = $ea[0];
  #   Nil;
  # }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_error_get_type, $n, $t );
  }

  method set_error_literal (GQuark $domain, Int() $code, Str() $message)
    is also<set-error-literal>
  {
    # g_set_error_literal($!e, $domain, $code, $message);
    my gint $c = $code;
    self.free;
    $!e = GError.new($domain, $c, $message);
  }

  method matches (GQuark $domain, Int() $code) {
    my gint $c = $code;

    so g_error_matches($!e, $domain, $code);
  }

}
