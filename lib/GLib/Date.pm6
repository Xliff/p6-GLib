use v6.c;

use Method::Also;

use GLib::Compat::Definitions;
use GLib::Raw::Types;
use GLib::Raw::Date;

use GLib::Roles::StaticClass;

class GLib::Date {
  has GDate $!d;

  submethod BUILD (:$date) {
    $!d = $date;
  }

  method GLib::Raw::Structs::GDate
    is also<GDate>
  { $!d }

  multi method new (GDate $date) {
    $date ?? self.bless( :$date ) !! Nil;
  }
  multi method new {
    my $date = g_date_new();

    $date ?? self.bless( :$date ) !! Nil;
  }

  method new_dmy (Int() $day, Int() $month, Int() $year) is also<new-dmy> {
    my guint8     $d = $day;
    my GDateMonth $m = $month;
    my guint16    $y = $year;

    my $date = g_date_new_dmy($d, $m, $y);

    $date ?? self.bless( :$date ) !! Nil;
  }

  method new_julian (Int() $julian_day) is also<new-julian> {
    my guint32 $j    = $julian_day;
    my         $date = g_date_new_julian($j);

    $date ?? self.bless( :$date ) !! Nil;
  }

  method add_days (Int() $n_days) is also<add-days> {
    my guint $n = $n_days;

    g_date_add_days($!d, $n);
  }

  method add_months (Int() $n_months) is also<add-months> {
    my guint $n = $n_months;

    g_date_add_months($!d, $n);
  }

  method add_years (Int() $n_years) is also<add-years> {
    my guint $n = $n_years;

    g_date_add_years($!d, $n);
  }

  method clamp (GDate() $min_date, GDate() $max_date) {
    g_date_clamp($!d, $min_date, $max_date);
  }

  multi method clear (GLib::Date:D: ) {
    GLib::Date.clear($!d, 1);
  }
  multi method clear (GLib::Date:U: GDate $date) {
    samewith($date, 1);
  }
  multi method clear (GLib::Date:U: gpointer $dates, Int() $n_dates) {
    my guint $n = $n_dates;

    g_date_clear($!d, $n);
  }

  multi method compare (GLib::Date:D: GDate() $rhs) {
    GLib::Date.compare($!d, $rhs);
  }
  multi method compare (GLib::Date:U: GDate $lhs, GDate $rhs) {
    g_date_compare($lhs, $rhs);
  }

  multi method copy (GLib::Date:D: :$raw) {
    GLib::Date.copy($!d, :$raw);
  }
  multi method copy (GLib::Date:U: GDate $date, :$raw = False) {
    my $d = g_date_copy($date);

    $d ??
      ( $raw ?? $d !! GLib::Date.new($d) )
      !!
      Nil;
  }

  proto method days_between
    is also<days-between>
  { * }

  multi method days_between (GLib::Date:D: GDate() $date2) {
    GLib::Date.days_between($!d, $date2);
  }
  multi method days_between (GLib::Date:U: GDate $date1, GDate $date2) {
    g_date_days_between($date1, $date2);
  }

  multi method free (GLib::Date:D: ) {
    GLib::Date.free($!d);
  }
  multi method free (GLib::Date:U: GDate $date) {
    g_date_free($date);
  }

  method get_day is also<get-day> {
    g_date_get_day($!d);
  }

  method get_day_of_year is also<get-day-of-year> {
    g_date_get_day_of_year($!d);
  }

  method get_days_in_month (Int $month, Int() $year) is also<get-days-in-month> {
    my GDateMonth $m = $month;
    my guint16    $y = $year;

    g_date_get_days_in_month($m, $y);
  }

  method get_iso8601_week_of_year is also<get-iso8601-week-of-year> {
    g_date_get_iso8601_week_of_year($!d);
  }

  method get_julian is also<get-julian> {
    g_date_get_julian($!d);
  }

  method get_monday_week_of_year is also<get-monday-week-of-year> {
    g_date_get_monday_week_of_year($!d);
  }

  method get_monday_weeks_in_year (Int() $year) is also<get-monday-weeks-in-year> {
    my guint16 $y = $year;

    g_date_get_monday_weeks_in_year($y);
  }

  method get_month is also<get-month> {
    g_date_get_month($!d);
  }

  method get_sunday_week_of_year is also<get-sunday-week-of-year> {
    g_date_get_sunday_week_of_year($!d);
  }

  method get_sunday_weeks_in_year (Int() $year) is also<get-sunday-weeks-in-year> {
    my guint16 $y = $year;

    g_date_get_sunday_weeks_in_year($y);
  }

  method get_weekday is also<get-weekday> {
    g_date_get_weekday($!d);
  }

  method get_year is also<get-year> {
    g_date_get_year($!d);
  }

  method is_first_of_month is also<is-first-of-month> {
    g_date_is_first_of_month($!d);
  }

  method is_last_of_month is also<is-last-of-month> {
    g_date_is_last_of_month($!d);
  }

  method is_leap_year (Int() $year) is also<is-leap-year> {
    my guint16 $y = $year;

    g_date_is_leap_year($y);
  }

  method order (GLib::Date:U: GDate $date1, GDate $date2) {
    g_date_order($date1, $date2);
  }

  method set_day (Int() $day) is also<set-day> {
    my guint8 $d = $day;

    g_date_set_day($!d, $d);
  }

  method set_dmy (Int() $day, Int() $month, Int() $year) is also<set-dmy> {
    my guint8     $d = $day;
    my GDateMonth $m = $month;
    my guint16    $y = $year;

    g_date_set_dmy($!d, $d, $m, $y);
  }

  method set_julian (Int() $julian_date) is also<set-julian> {
    my guint32 $j = $julian_date;

    g_date_set_julian($!d, $j);
  }

  method set_month (Int() $month) is also<set-month> {
    my GDateMonth $m = $month;

    g_date_set_month($!d, $m);
  }

  method set_parse (Str() $str) is also<set-parse> {
    g_date_set_parse($!d, $str);
  }

  method set_time (Int() $time) is also<set-time> {
    my guint32 $t = $time; # GTime

    g_date_set_time($!d, $time);
  }

  method set_time_t (time_t $timet) is also<set-time-t> {
    g_date_set_time_t($!d, $timet);
  }

  method set_time_val (GTimeVal $timeval) is also<set-time-val> {
    g_date_set_time_val($!d, $timeval);
  }

  method set_year (Int() $year) is also<set-year> {
    my guint16 $y = $year;

    g_date_set_year($!d, $y);
  }

  method strftime (
    GLib::Date:U:
    Str()         $s,
    Int()         $slen,
    Str()         $format,
    GDate()       $date
  ) {
    my gsize $sl = $slen;

    g_date_strftime($s, $sl, $format, $date);
  }

  method subtract_days (Int() $n_days) is also<subtract-days> {
    my guint $n = $n_days;

    g_date_subtract_days($!d, $n);
  }

  method subtract_months (Int() $n_months) is also<subtract-months> {
    my guint $n = $n_months;

    g_date_subtract_months($!d, $n);
  }

  method subtract_years (Int() $n_years) is also<subtract-years> {
    my guint $n = $n_years;

    g_date_subtract_years($!d, $n);
  }

  method to_struct_tm (tm $tm) is also<to-struct-tm> {
    g_date_to_struct_tm($!d, $tm);
  }

  multi method valid (GLib::Date:D: ) {
    GLib::Date.valid($!d);
  }
  multi method valid (GLib::Date:U: GDate $date) {
    so g_date_valid($date);
  }

  method valid_day (GLib::Date:U: Int() $day) is also<valid-day> {
    my guint8 $d = $day;

    so g_date_valid_day($d);
  }

  method valid_dmy (
    GLib::Date:U:
    Int()         $day,
    Int()         $month,
    Int()         $year
  )
    is also<valid-dmy>
  {
    my guint8     $d = $day;
    my GDateMonth $m = $month;
    my guint16    $y = $year;

    so g_date_valid_dmy($d, $m, $y);
  }

  method valid_julian (Int() $julian_date) is also<valid-julian> {
    my guint32 $j = $julian_date;

    so g_date_valid_julian($j);
  }

  method valid_month (Int() $month) is also<valid-month> {
    my GDateMonth $m = $month;

    so g_date_valid_month($m);
  }

  method valid_weekday (Int() $weekday) is also<valid-weekday> {
    my GDateWeekday $w = $weekday;

    so g_date_valid_weekday($w);
  }

  method valid_year (Int() $year) is also<valid-year> {
    my guint16 $y = $year;

    so g_date_valid_year($year);
  }

}
