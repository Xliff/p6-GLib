use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Thread;

class GLib::Mutex {
  has GMutex $!m is implementor handles<p>;

  submethod BUILD (:$mutex) {
    $!m = $mutex;
  }

  method GLib::Raw::Structs::GMutex
    is also<GMutex>
  { $!m }

  multi method new (GMutex $mutex) {
    $mutex ?? self.bless( :$mutex ) !! Nil;
  }
  multi method new {
    # No need for Nil check since its a struct.
    my $mutex = GMutex.new;
    return Nil unless $mutex;

    GLib::Mutex.init($mutex);
    self.bless( :$mutex );
  }

  method clear {
    g_mutex_clear($!m);
  }

  method init (GLib::Mutex:U: $mutex) {
    g_mutex_init($mutex);
  }

  method lock {
    g_mutex_lock($!m);
  }

  method trylock {
    g_mutex_trylock($!m);
  }

  method unlock {
    g_mutex_unlock($!m);
  }

}
