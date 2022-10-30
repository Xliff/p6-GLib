use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Main;

use GLib::Source;

use GLib::Roles::StaticClass;

class GLib::Timeout {
  also does GLib::Roles::StaticClass;

  method add (
    Int()     $interval,
              &function,
    gpointer  $data      = gpointer,
    Str()    :$name      = Str
  ) {
    my guint $i = $interval;

    my $id = g_timeout_add($i, &function, $data);
    GLib::Source.set-name-by-id($id, $name) if $name;
    $id;
  }

  method add_full (
    Int()           $priority,
    Int()           $interval,
                    &function,
    gpointer        $data      = gpointer,
                    $notify    = %DEFAULT-CALLBACKS<GDestroyNotify>,
    Str()          :$name      = Str
  )
    is also<add-full>
  {
    my gint  $p = $priority;
    my guint $i = $interval;

    my $id = g_timeout_add_full($p, $i, &function, $data, $notify);
    GLib::Source.set-name-by-id($id, $name) if $name;
    $id;
  }

  method add_seconds (
    Int()     $interval,
              &function,
    gpointer  $data      = gpointer,
    Str()    :$name      = Str

  )
    is also<add-seconds>
  {
    my guint $i = $interval;

    my $id = g_timeout_add_seconds($i, &function, $data);
    GLib::Source.set-name-by-id($id, $name) if $name;
    $id;
  }

  method add_seconds_full (
    Int()          $priority,
    Int()          $interval,
                   &function,
    gpointer       $data      = gpointer,
                   $notify    = %DEFAULT-CALLBACKS<GDestroyNotify>,
    Str()         :$name      = Str
  )
    is also<add-seconds-full>
  {
    my gint  $p = $priority;
    my guint $i = $interval;

    my $id = g_timeout_add_seconds_full($p, $i, &function, $data, $notify);
    GLib::Source.set-name-by-id($id, $name) if $name;
    $id;
  }

  # Lifted from GTK::Simple. Provided for compatibility.
  method simple_timeout(Cool $msecs) is also<simple-timeout> {
    use nqp;
    use NativeCall;

    my $s = Supplier.new;
    my $starttime = nqp::time_n();
    my $lasttime  = nqp::time_n();

    g_timeout_add(
        $msecs.Int,
        sub (*@) {
            my $dt = nqp::time_n() - $lasttime;
            $lasttime = nqp::time_n();
            $s.emit((nqp::time_n() - $starttime, $dt));

            return 1;
        },
        Pointer
    );
    return $s.Supply;
  }

  method simple_timeout_in_seconds(Cool $sec)
    is also<simple-timeout-in-seconds>
  {
    GLib::Timeout.simple-timeout($sec * 1000);
  }

  method cancel (Int() $tag) {
    GLib::Source.remove($tag);
  }

}
