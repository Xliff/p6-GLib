use v6.c;

use NativeCall;

use GLib::Compat::Definitions;
use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Structs;

unit package GLib::Raw::Date;

### /usr/include/glib-2.0/glib/gdate.h

sub g_date_add_days (GDate $date, guint $n_days)
  is native(glib)
  is export
{ * }

sub g_date_add_months (GDate $date, guint $n_months)
  is native(glib)
  is export
{ * }

sub g_date_add_years (GDate $date, guint $n_years)
  is native(glib)
  is export
{ * }

sub g_date_clamp (GDate $date, GDate $min_date, GDate $max_date)
  is native(glib)
  is export
{ * }

sub g_date_clear (GDate $date, guint $n_dates)
  is native(glib)
  is export
{ * }

sub g_date_compare (GDate $lhs, GDate $rhs)
  returns gint
  is native(glib)
  is export
{ * }

sub g_date_copy (GDate $date)
  returns GDate
  is native(glib)
  is export
{ * }

sub g_date_days_between (GDate $date1, GDate $date2)
  returns gint
  is native(glib)
  is export
{ * }

sub g_date_free (GDate $date)
  is native(glib)
  is export
{ * }

sub g_date_get_day (GDate $date)
  returns guint8
  is native(glib)
  is export
{ * }

sub g_date_get_day_of_year (GDate $date)
  returns guint
  is native(glib)
  is export
{ * }

sub g_date_get_days_in_month (GDateMonth $month, guint16 $year)
  returns guint8
  is native(glib)
  is export
{ * }

sub g_date_get_iso8601_week_of_year (GDate $date)
  returns guint
  is native(glib)
  is export
{ * }

sub g_date_get_julian (GDate $date)
  returns guint32
  is native(glib)
  is export
{ * }

sub g_date_get_monday_week_of_year (GDate $date)
  returns guint
  is native(glib)
  is export
{ * }

sub g_date_get_monday_weeks_in_year (guint16 $year)
  returns guint8
  is native(glib)
  is export
{ * }

sub g_date_get_month (GDate $date)
  returns GDateMonth
  is native(glib)
  is export
{ * }

sub g_date_get_sunday_week_of_year (GDate $date)
  returns guint
  is native(glib)
  is export
{ * }

sub g_date_get_sunday_weeks_in_year (guint16 $year)
  returns guint8
  is native(glib)
  is export
{ * }

sub g_date_get_weekday (GDate $date)
  returns GDateWeekday
  is native(glib)
  is export
{ * }

sub g_date_get_year (GDate $date)
  returns guint16
  is native(glib)
  is export
{ * }

sub g_date_is_first_of_month (GDate $date)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_is_last_of_month (GDate $date)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_is_leap_year (guint16 $year)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_new ()
  returns GDate
  is native(glib)
  is export
{ * }

sub g_date_new_dmy (guint8 $day, GDateMonth $month, guint16 $year)
  returns GDate
  is native(glib)
  is export
{ * }

sub g_date_new_julian (guint32 $julian_day)
  returns GDate
  is native(glib)
  is export
{ * }

sub g_date_order (GDate $date1, GDate $date2)
  is native(glib)
  is export
{ * }

sub g_date_set_day (GDate $date, guint8 $day)
  is native(glib)
  is export
{ * }

sub g_date_set_dmy (GDate $date, guint8 $day, GDateMonth $month, guint16 $y)
  is native(glib)
  is export
{ * }

sub g_date_set_julian (GDate $date, guint32 $julian_date)
  is native(glib)
  is export
{ * }

sub g_date_set_month (GDate $date, GDateMonth $month)
  is native(glib)
  is export
{ * }

sub g_date_set_parse (GDate $date, Str $str)
  is native(glib)
  is export
{ * }

sub g_date_set_time (GDate $date, guint32 $time_)
  is native(glib)
  is export
{ * }

sub g_date_set_time_t (GDate $date, time_t $timet)
  is native(glib)
  is export
{ * }

sub g_date_set_time_val (GDate $date, GTimeVal $timeval)
  is native(glib)
  is export
{ * }

sub g_date_set_year (GDate $date, guint16 $year)
  is native(glib)
  is export
{ * }

sub g_date_strftime (Pointer $s, gsize $slen, Str $format, GDate $date)
  returns gsize
  is native(glib)
  is export
{ * }

sub g_date_subtract_days (GDate $date, guint $n_days)
  is native(glib)
  is export
{ * }

sub g_date_subtract_months (GDate $date, guint $n_months)
  is native(glib)
  is export
{ * }

sub g_date_subtract_years (GDate $date, guint $n_years)
  is native(glib)
  is export
{ * }

sub g_date_to_struct_tm (GDate $date, tm $tm)
  is native(glib)
  is export
{ * }

sub g_date_valid (GDate $date)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_valid_day (guint8 $day)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_valid_dmy (guint8 $day, GDateMonth $month, guint16 $year)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_valid_julian (guint32 $julian_date)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_valid_month (GDateMonth $month)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_valid_weekday (GDateWeekday $weekday)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_date_valid_year (guint16 $year)
  returns uint32
  is native(glib)
  is export
{ * }
