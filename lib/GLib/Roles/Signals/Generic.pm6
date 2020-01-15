use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::ReturnedValue;
use GLib::Raw::Signal;

role GLib::Roles::Signals::Generic {
  has %!signals;
  has %!tapped-sigs;

  # Has this supply been created yet? If True, this is a good indication that
  # that signal $name has been tapped. It IS an indicator that the Supply
  # has been created.
  #
  # Must be overridden by all consumers that use another Signal-based role.
  method is-connected(Str $name) is also<is_connected> {
    #$%!signals{$name}:exists;
    %!tapped-sigs{$name}:exists;
  }

  # If I cannot share attributes between roles, then each one will have
  # to have its own signature, or clean-up routine.
  method disconnect-all (%sigs) is also<disconnect_all> {
    self.disconnect($_, %sigs) for %sigs.keys;
  }

  method disconnect($signal, %signals) {
    # First parameter is good, but concerned about the second.
    g_signal_handler_disconnect(%signals{$signal}[1], %signals{$signal}[2]);
    %signals{$signal}:delete;
  }

  method connect(
    $obj,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      #"O: $obj".say;
      #"S: $signal".say;
      $hid = g_connect($obj, $signal,
        -> $, $ud {
            $s.emit( [self, $ud] );
            CATCH { default { note($_) } }
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-ruint (
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_ruint
      connect_rbool
      connect-rbool
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_rbool($obj, $signal,
        -> $, $ud --> gboolean {
          CATCH {
            default { note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $ud, $r] );
          #die 'Invalid return type' if $r.r ~~ Bool;
          #$r.r = .Int if $r.r ~~ Bool;
          $r.r;
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-string (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_string>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_string($obj, $signal,
        -> $, $s, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $s, $ud] );
        },
        Pointer, 0
      );
      my $supply = $s.Supply;
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-strstr (
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_strstr
      connect_2str
      connect-2str
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_strstr($obj, $signal,
        -> $, $s1, $s2, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $s1, $s2, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-int (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_int>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_int($obj, $signal,
        -> $, $i, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $i, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # Pointer, guint, guint, gpointer
  method connect-uintuint (
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_uintuint
      connect_2uint
      connect-2uint
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-uintuint($obj, $signal,
        -> $, $ui1, $ui2, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui1, $ui2, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # Pointer, gint, gint, gpointer
  method connect-intint (
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_intint
      connect-2int
      connect_2int
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-intint($obj, $signal,
        -> $, $i1, $i2, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $i1, $i2, $ud ] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uint (
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_uint
      connect-bool
      connect_bool
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_uint($obj, $signal,
        -> $, $ui, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-double (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_double>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_double($obj, $signal,
        -> $, $d, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $d, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-long (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_long>
  {
    my $hid;
    %!signals //= do {
      my $s = Supplier.new;
      $hid = g-connect-long($obj, $signal,
        -> $, $l, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $l, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-strint (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_strint>
  {
    my $hid;
    %!signals //= do {
      my $s = Supplier.new;
      $hid = g-connect-strint($obj, $signal,
        -> $, $s, $i, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $s, $i, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uintint (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_uintint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_uintint($obj, $signal,
        -> $, $ui, $i, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui, $i, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uintintbool (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_uintintbool>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_uintintbool($obj, $signal,
        -> $, $ui, $i, $b, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui, $i, $b, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-str-rbool (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_str_rbool>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_str_rbool($obj, $signal,
        -> $, $uri, $ud --> gboolean {
          CATCH {
            default { note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $uri, $ud, $r] );
          # die 'Invalid return type' if $r.r ~~ Bool;
          # $r.r = .Int if $r.r ~~ Bool;
          $r.r;
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-int-rint (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_int_rint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_int_ruint($obj, $signal,
        -> $, $i, $ud --> gint {
          CATCH {
            default { note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $i, $ud, $r] );
          # $r.r .= Int if $r.r ~~ (Bool, Enumeration).any;
          $r.r;
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-int-ruint (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_int_ruint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_int_ruint($obj, $signal,
        -> $, $i, $ud --> guint {
          CATCH {
            default { note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $i, $ud, $r] );
          # $r.r .= Int if $r.r ~~ (Bool, Enumeration).any;
          $r.r;
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uint-ruint (
    $obj,
    $signal,
    &handler?
  )
    is also<connect_uint_ruint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_uint_ruint($obj, $signal,
        -> $, $ui, $ud --> guint {
          CATCH {
            default { note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $ui, $ud, $r] );
          # $r.r .= Int if $r.r ~~ (Bool, Enumeration).any;
          $r.r;
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-gparam(
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_gparam
      connect-param
      connect_param
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-gparam($obj, $signal,
        -> $, $gp, $ud {
          CATCH { default { note($_) } }

          $s.emit( [self, $gp, $ud] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GSimpleAction, GVariant, gpointer
  method connect-gvariant (
    $obj,
    $signal,
    &handler?
  )
    is also<
      connect_gvariant
      connect_variant
      connect-variant
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-variant($obj, $signal,
        -> $, $v, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $v, $ud ] );
        },
        Pointer, 0
      );
      [ create-signal-supply(%!tapped-sigs, $signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

}

sub g_connect(
  Pointer $app,
  Str $name,
  &handler (GObject $h_widget, Pointer $h_data),
  Pointer $data,
  uint32 $connect_flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_rbool(
  Pointer $app,
  Str $name,
  &handler (Pointer, Pointer --> gboolean),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_string(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_strstr(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, Str, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g-connect-intint(
  Pointer $app,
  Str $name,
  &handler (Pointer, gint, gint, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g-connect-uintuint(
  Pointer $app,
  Str $name,
  &handler (Pointer, guint, guint, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_int(
  Pointer $app,
  Str $name,
  &handler (Pointer, gint, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

# Define for each signal
sub g_connect_uint(
  Pointer $app,
  Str $name,
  &handler (Pointer, uint32, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_double(
  Pointer $app,
  Str $name,
  &handler (Pointer, gdouble, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_pointer(
  Pointer $app,
  Str $name,
  &handler (Pointer, Pointer, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_uintint (
  Pointer $app,
  Str $name,
  &handler (Pointer, uint32, gint, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_uintintbool (
  Pointer $app,
  Str $name,
  &handler (Pointer, uint32, gint, gboolean, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_str_rbool(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, Pointer --> gboolean),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_int_ruint(
  Pointer $app,
  Str $name,
  &handler (Pointer, gint, Pointer --> guint),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_int_rint(
  Pointer $app,
  Str $name,
  &handler (Pointer, gint, Pointer --> gint),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_connect_uint_ruint(
  Pointer $app,
  Str $name,
  &handler (Pointer, guint, Pointer --> guint),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g-connect-uintint (
  Pointer $app,
  Str $name,
  &handler (Pointer, uint32, gint, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g-connect-gparam(
  Pointer $app,
  Str $name,
  &handler (Pointer, GParamSpec, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

# Pointer, guint64, gpointer
sub g-connect-long(
  Pointer $app,
  Str $name,
  &handler (Pointer, guint64, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

# Pointer, Str, gint, gpointer
sub g-connect-strint(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, gint, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

# Pointer, GVariant, Pointer
sub g-connect-variant(
  Pointer $app,
  Str $name,
  &handler (Pointer, GVariant, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }
