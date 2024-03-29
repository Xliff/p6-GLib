use v6.c;

use NativeCall;

use GLib::Raw::Types;

unit package GLib::Raw::Timer;

### /usr/src/glib2.0-2.68.4/glib/gtimer.h

sub g_timer_continue (GTimer $timer)
  is native(glib)
  is export
{ * }

sub g_timer_destroy (GTimer $timer)
  is native(glib)
  is export
{ * }

sub g_timer_elapsed (GTimer $timer, gulong $microseconds)
  returns gdouble
  is native(glib)
  is export
{ * }

sub g_time_val_add (GTimeVal $time_, gulong $microseconds)
  is native(glib)
  is export
{ * }

sub g_time_val_from_iso8601 (Str $iso_date, GTimeVal $time_)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_time_val_to_iso8601 (GTimeVal $time_)
  returns Str
  is native(glib)
  is export
{ * }

sub g_usleep (gulong $microseconds)
  is native(glib)
  is export
{ * }

sub g_timer_new ()
  returns GTimer
  is native(glib)
  is export
{ * }

sub g_timer_reset (GTimer $timer)
  is native(glib)
  is export
{ * }

sub g_timer_start (GTimer $timer)
  is native(glib)
  is export
{ * }

sub g_timer_stop (GTimer $timer)
  is native(glib)
  is export
{ * }
