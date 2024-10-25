use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::ReturnedValue;
use GLib::Raw::Signal;
use GLib::Object::Supplyish;

role SignalManager { }

multi sub trait_mod:<is> (Attribute \a, :$signal-manager is required)
  is export
{
  a does SignalManager;
}

role GLib::Roles::Signals::Generic {
  has %!tapped-sigs;
  has %!signals      is signal-manager;

  method signal-manager {
    for self.^attributes.grep(SignalManager) {
      if .get-value(self) -> $h {
        return $h;
      }
    }
    Nil;
  }

  method get-signal-id ($name) {
    if $.signal-manager{$name} -> $S {
      $S ~~ GLib::Object::Supplyish ?? $S.signal !! $S.tail;
    }
  }

  method create-signal-supply ($signal, $s) {
    create-signal-supply($s, %!tapped-sigs, $signal);
  }

  # Has this supply been created yet? If True, this is a good indication that
  # that signal $name has been tapped. It IS an indicator that the Supply
  # has been created.
  #
  # Must be overridden by all consumers that use another Signal-based role.
  method is-connected (Str $name) is also<is_connected> {
    #$%!signals{$name}:exists;
    %!tapped-sigs{$name}:exists;
  }

  # If I cannot share attributes between roles, then each one will have
  # to have its own signature, or clean-up routine.
  method disconnect-all ($sig) is also<disconnect_all> {
    self.disconnect($_) for $sig.keys;
  }

  method disconnect ($signal) {
    g_signal_handler_disconnect(
      %!signals{$signal}[1],
      self.get-signal-id($signal);
    );
    %!signals{$signal}:delete;
  }

  method setSignal($name, $data) {
    %!signals{$name} = $data;
  }

  method getSignal($name) {
    %!signals{$name};
  }

  multi method connect (
    $obj is copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      "O: $obj".say    if $DEBUG;
      "S: $signal".say if $DEBUG;
      $obj .= p if $obj.^can('p');

      $hid = g_connect($obj, $signal,
        -> $, $ud {
            $s.emit( [self, $ud] );
            CATCH { default { note($_) } }
        },
        Pointer, 0
      );
      "H: $hid".say if $DEBUG;
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-ruint (
    $obj     is copy,
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
      $obj .= p if $obj.^can('p');
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
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-rdouble (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_rdouble>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_rdouble($obj, $signal,
        -> $, $ud --> gdouble {
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
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-string (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<
      connect_string
      connect_str
      connect-str
    >
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_string($obj, $signal,
        -> $, $s1, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $s1, $ud] );
        },
        Pointer, 0
      );
      my $supply = $s.Supply;
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-strstr (
    $obj is copy,
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
      $obj .= p if $obj.^can('p');
      $hid = g_connect_strstr($obj, $signal,
        -> $, $s1, $s2, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $s1, $s2, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-int (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_int>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_int($obj, $signal,
        -> $, $i, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $i, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-intuint (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_intuint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_intuint($obj, $signal,
        -> $, $i, $ui, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $i, $ui, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # Pointer, guint, guint, gpointer
  method connect-uintuint (
    $obj is copy,
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
      $obj .= p if $obj.^can('p');
      $hid = g-connect-uintuint($obj, $signal,
        -> $, $ui1, $ui2, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui1, $ui2, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # Pointer, gint, gint, gpointer
  method connect-intint (
    $obj is copy,
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
      $obj .= p if $obj.^can('p');
      $hid = g-connect-intint($obj, $signal,
        -> $, $i1, $i2, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $i1, $i2, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uint (
    $obj is copy,
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
      $obj .= p if $obj.^can('p');
      $hid = g_connect_uint($obj, $signal,
        -> $, $ui, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-double (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_double>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_double($obj, $signal,
        -> $, $d, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $d, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-pdouble (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_pdouble>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_pdouble($obj, $signal,
        -> $, $d is rw, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $d, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-long (
    $obj is copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-long($obj, $signal,
        -> $, $l, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $l, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # cw: OG Aliasing.
  method connect_long  (|c) { self.connect-long(|c) }
  method connect_ulong (|c) { self.connect-long(|c) }
  method connect-ulong (|c) { self.connect-long(|c) }

  method connect-strint (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_strint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-strint($obj, $signal,
        -> $, $s1, $i1, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $s1, $i1, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uintint (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_uintint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_uintint($obj, $signal,
        -> $, $ui, $i, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui, $i, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uintintbool (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_uintintbool>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g_connect_uintintbool($obj, $signal,
        -> $, $ui, $i, $b, $ud {
          CATCH {
            default { note($_) }
          }

          $s.emit( [self, $ui, $i, $b, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-str-rbool (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_str_rbool>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
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
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-int-rint (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_int_rint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
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
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-int-ruint (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_int_ruint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
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
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-uint-ruint (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect_uint_ruint>
  {
    my $hid;
    %!signals{$signal} //= do {
      my $s = Supplier.new;
      $obj .= p if $obj.^can('p');
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
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  method connect-gparam (
    $obj is copy,
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
      $obj .= p if $obj.^can('p');
      $hid = g-connect-gparam($obj, $signal,
        -> $, $gp, $ud {
          CATCH { default { note($_) } }

          $s.emit( [self, $gp, $ud] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GSimpleAction, GVariant, gpointer
  method connect-gvariant (
    $obj is copy,
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
      $obj .= p if $obj.^can('p');
      $hid = g-connect-variant($obj, $signal,
        -> $, $v, $ud {
          CATCH {
            default { $s.quit($_) }
          }

          $s.emit( [self, $v, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, $s), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

    # GstAppSrc, guint64, gpointer --> gboolean
  method connect-long-ruint32 (
    $obj is copy,
    $signal,
    &handler?
  )
    is also<connect-long-rbool>
  {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-long-ruint32($obj, $signal,
        -> $, $gt, $gr, $ud --> gboolean {
          CATCH {
            default { 𝒮.note($_) }
          }

          my $r = ReturnedValue.new;
          𝒮.emit( [self, $gt, $gr, $ud, $r] );
          $r.r;
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GObject, GError, gpointer
  method connect-error (
    $obj is copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-error($obj, $signal,
        -> $, $e, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $e, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GObject, GError, gpointer
  method connect-pointer (
    $obj is copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-error($obj, $signal,
        -> $, $p, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $p, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GObject, GObject, gpointer
  method connect-object (
    $obj is copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-object($obj, $signal,
        -> $, $o, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $o, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GObject, gdouble, gdouble, gpointer
  method connect-num (
    $obj is      copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-num($obj, $signal,
        -> $, $n1, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $n1, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GObject, gdouble, gdouble, gpointer
  method connect-numnum (
    $signal,
    $obj is copy,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-numnum($obj, $signal,
        -> $, $n1, $n2, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $n1, $n2, $ud ] );
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

  # GObject, gdouble, gdouble, gpointer
  method connect-numnum-ruint (
    $obj is copy,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals{$signal} //= do {
      my \𝒮 = Supplier.new;
      $obj .= p if $obj.^can('p');
      $hid = g-connect-numnum-ruint($obj, $signal,
        -> $, $n1, $n2, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          my $r = GLib::Raw::ReturnedValue.new;
          𝒮.emit( [self, $n1, $n2, $ud, $r ] );
          $r.r.Int;
        },
        Pointer, 0
      );
      [ self.create-signal-supply($signal, 𝒮), $obj, $hid ];
    };
    %!signals{$signal}[0].tap(&handler) with &handler;
    %!signals{$signal}[0];
  }

}

# cw: Note, at the generic level, it's easier to convert the invocant
#     to Pointer. Note that GObject is basically a Pointer anyways.

sub g_connect (
  Pointer $app,
  Str     $name,
          &handler (GObject $h_widget, Pointer $h_data),
  Pointer $data,
  uint32  $connect_flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_rbool (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Pointer --> gboolean),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_string (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Str, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_strstr (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Str, Str, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g-connect-intint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gint, gint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g-connect-uintuint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, guint, guint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_int (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_intuint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gint, guint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

# Define for each signal
sub g_connect_uint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, uint32, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_double (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gdouble, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_pdouble (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gdouble is rw, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_rdouble (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Pointer --> gdouble),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_pointer (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Pointer, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_uintint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, uint32, gint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_uintintbool (
  Pointer $app,
  Str     $name,
          &handler (Pointer, uint32, gint, gboolean, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_str_rbool (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Str, Pointer --> gboolean),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_int_ruint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gint, Pointer --> guint),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_int_rint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, gint, Pointer --> gint),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g_connect_uint_ruint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, guint, Pointer --> guint),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g-connect-uintint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, uint32, gint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

sub g-connect-gparam (
  Pointer $app,
  Str     $name,
          &handler (Pointer, GParamSpec, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

# Pointer, guint64, gpointer
sub g-connect-long (
  Pointer $app,
  Str     $name,
          &handler (Pointer, guint64, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

# Pointer, Str, gint, gpointer
sub g-connect-strint (
  Pointer $app,
  Str     $name,
          &handler (Pointer, Str, gint, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }

# Pointer, GVariant, Pointer
sub g-connect-variant (
  Pointer $app,
  Str     $name,
          &handler (Pointer, GVariant, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native('gobject-2.0')
  is      symbol('g_signal_connect_object')
{ * }


# GObject, guint64, gpointer --> gboolean
sub g-connect-long-ruint32 (
  Pointer $app,
  Str     $name,
          &handler (Pointer, guint64, Pointer --> guint32),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }

# GObject, GError, gpointer
sub g-connect-error(
  Pointer $app,
  Str     $name,
          &handler (Pointer, GError, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }

# GObject, gpointer, gpointer
sub g-connect-pointer(
  Pointer $app,
  Str     $name,
          &handler (Pointer, Pointer, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }

# GObject, GObject, gpointer
sub g-connect-object(
  Pointer $app,
  Str     $name,
          &handler (Pointer, GObject, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }

# GObject, gdouble, gdouble, gpointer
sub g-connect-numnum(
  Pointer $app,
  Str     $name,
          &handler (Pointer, gdouble, gdouble, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }

# GObject, gdouble, gdouble, gpointer
sub g-connect-num(
  Pointer $app,
  Str     $name,
          &handler (Pointer, gdouble, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }

# GObject, gdouble, gdouble, gpointer --> guint32
sub g-connect-numnum-ruint(
  Pointer $app,
  Str     $name,
          &handler (Pointer, gdouble, gdouble, Pointer --> guint32),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is      native(gobject)
  is      symbol('g_signal_connect_object')
{ * }
