use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Thread;

class GLib::Cond {
  has GCond $!c is implementor handles<p>;

  submethod BUILD (:$cond) {
    $!c = $cond;
  }

  method GLib::Raw::Structs::GCond
    is also<GCond>
  { $!c }

  multi method new (GCond $cond) {
    $cond ?? self.bless( :$cond ) !! Nil;
  }
  multi method new {
    my $cond = GCond.new;
    GLib::Cond.init($cond);

    $cond ?? self.bless( :$cond ) !! Nil;
  }

  method broadcast {
    g_cond_broadcast($!c);
  }

  method clear {
    g_cond_clear($!c);
  }

  method init (GLib::Cond:U: GCond $to-init) {
    g_cond_init($to-init);
  }

  method signal {
    g_cond_signal($!c);
  }

  method wait (GMutex() $mutex) {
    g_cond_wait($!c, $mutex);
  }

  method wait_until (GMutex() $mutex, Int() $end_time) is also<wait-until> {
    my gint64 $e = $end_time;

    so g_cond_wait_until($!c, $mutex, $e);
  }

}
