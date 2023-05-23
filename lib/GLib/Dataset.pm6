use v6.c;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Dataset;

class GLib::Dataset {
  also does GLib::Roles::Implementor;

  has GDataset $!d is implementor;

  submethod BUILD ( :$data ) {
    $!d = $data ~~ Pointer ;
  }

  multi method new (Pointer $data) {
    return Nil unless $data;

    self.bless( :$data );
  }
  multi method new (GData $data) {
    return Nil unless $data;

    my $d = newCArray(GData, $data);

    self.bless( data => cast(Pointer, $d) );
  }

  method Hash {
    my $h = %{};

    self.foreach( -> *@a {
      $h{ GLib::Quark.to-string(@a.head) } = @a.tail;
    });

    $h
  }

  # cw: Do NOT use destroy from here. Reap using the original object or
  #     free the original pointer!
  # method destroy {
  #   g_dataset_destroy($!d);
  # }

  method foreach (
                     &func,
    gpointer         $user_data = gpointer
  ) {
    g_dataset_foreach($!d, &func, $user_data);
  }

  method id_set_data (GQuark $k, $d) {
    self.id_set_data_full($!d, $k, $d);
  }

  method id_remove_data ($k) {
    # cw: Mustfix
    #g_dataset_id_set_data($!d, $k, gpointer);
  }

  method get_data (Str() $k) {
    self.id_get_data( $!d, GLib::Quark.try_string($k) )
  }

  multi method set_data_full (
    Str()     $k,
              $d,
             :$notify = %DEFAULT-CALLBACKS<GDestroyNotify>,
             :$signed = False,
             :$double = True,
             :$direct = False,
  ) {
    self.set_data_full(
      $k,
      toPointer($d, :$signed, :$double, :$direct),
      $notify
    );
  }
  multi method set_data_full (
    Str()    $k,
    gpointer $d,
             &f = %DEFAULT-CALLBACKS<GDestroyNotify>
  ) {
    self.id_set_data_full(
      $!d,
      GLib::Quark.from_string($k),
      $d,
      &f
    )
  }

  method remove_no_notify (Str() $k) {
    g_dataset_id_remove_no_notify(
      $!d,
      GLib::Quark.try_string($k)
    );
  }

  method set_data(GQuark $k, gpointer $d) {
    self.set_data_full($k, $d)
  }

  method remove_data (Str() $k) {
    self.id_set_data( $!d,  GLib::Quark.try_string($k) )
  }

  method id_get_data (GQuark $key_id) {
    # cw: MUST FIX!
    #g_dataset_id_get_data($!d, $key_id);
  }

  method id_remove_no_notify (GQuark $key_id) {
    # cw: MUST FIX!
    #g_dataset_id_remove_no_notify($!d, $key_id);
  }

  method id_set_data_full (
    GQuark         $key_id,
    gpointer       $data,
                   &destroy_func = %DEFAULT-CALLBACKS<GDestroyNotify>
  ) {
    g_dataset_id_set_data_full($!d, $key_id, $data, &destroy_func);
  }

}


# cw: Currently NYI, for now.
class GLib::DataList {
    has $!dl;

    method g_datalist_clear {
      g_datalist_clear($!dl);
    }

    method g_datalist_foreach (
      CArray[GData]    $datalist,
                       &func,
      gpointer         $user_data
    ) {
      g_datalist_foreach($!dl, &func, $user_data);
    }

    method g_datalist_get_data (
      CArray[GData] $datalist,
      Str           $key
    ) {
      g_datalist_get_data($!dl, $key);
    }

    method g_datalist_get_flags {
      g_datalist_get_flags($!dl);
    }

    method g_datalist_id_dup_data (
      CArray[GData]  $datalist,
      GQuark         $key_id,
                     &dup_func,
      gpointer       $user_data
    ) {
      g_datalist_id_dup_data($!dl, $key_id, &dup_func, $user_data);
    }

    method g_datalist_id_get_data (
      CArray[GData] $datalist,
      GQuark        $key_id
    ) {
      g_datalist_id_get_data($!dl, $key_id);
    }

    method g_datalist_id_remove_no_notify (
      CArray[GData] $datalist,
      GQuark        $key_id
    ) {
      g_datalist_id_remove_no_notify($!dl, $key_id);
    }

    method g_datalist_id_replace_data (
      CArray[GData]  $datalist,
      GQuark         $key_id,
      gpointer       $oldval,
      gpointer       $newval,
                     $destroy     = %DEFAULT-CALLBACKS<GDestroyNotify>,
                     $old_destroy = %DEFAULT-CALLBACKS<GDestroyNotify>
    ) {
      g_datalist_id_replace_data(
        $!dl,
        $key_id,
        $oldval,
        $newval,
        $destroy,
        $old_destroy
      );
    }

    method g_datalist_id_set_data_full (
      CArray[GData]  $datalist,
      GQuark         $key_id,
      gpointer       $data,
                     $destroy_func = %DEFAULT-CALLBACKS<GDestroyNotify>
    ) {
      g_datalist_id_set_data_full($!dl, $key_id, $data, $destroy_func);
    }

    method g_datalist_init {
      g_datalist_init($!dl);
    }

    method g_datalist_set_flags (
      CArray[GData] $datalist,
      guint         $flags
    ) {
      g_datalist_set_flags($!dl, $flags);
    }

    method g_datalist_unset_flags (
      CArray[GData] $datalist,
      guint         $flags
    ) {
      g_datalist_unset_flags($!dl, $flags);
    }
}
