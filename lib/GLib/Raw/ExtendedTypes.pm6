use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Subs;

### /usr/include/glib-2.0/gobject/glib-types.h

sub g_array_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_byte_array_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_bytes_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_checksum_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_date_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_date_time_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_error_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_gstring_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_hash_table_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_io_channel_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_io_condition_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_key_file_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_main_context_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_main_loop_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_mapped_file_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_markup_parse_context_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_match_info_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_option_group_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_pollfd_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_ptr_array_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_regex_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_source_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_strv_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_thread_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_time_zone_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_variant_builder_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_variant_dict_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_variant_get_gtype ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_variant_type_get_gtype ()
  returns GType
  is native(gobject)
  is export
{ * }

sub get_unstable_type ( &f ) {
  state (%n, %t);
  my $n = &f.name;

  unstable_get_type( 'ExtendedTypes-' ~ $n, &f, %n{$n}, %t{$n} );
}

our $G_TYPE_ARRAY                is export;
our $G_TYPE_BYTE_ARRAY           is export;
our $G_TYPE_BYTES                is export;
our $G_TYPE_CHECKSUM             is export;
our $G_TYPE_DATE                 is export;
our $G_TYPE_DATE_TIME            is export;
our $G_TYPE_ERROR                is export;
our $G_TYPE_GSTRING              is export;
our $G_TYPE_HASH_TABLE           is export;
our $G_TYPE_iO_CHANNEL           is export;
our $G_TYPE_IO_CONDITION         is export;
our $G_TYPE_KEY_FILE             is export;
our $G_TYPE_MAIN_CONTEXT         is export;
our $G_TYPE_MAIN_LOOP            is export;
our $G_TYPE_MAPPED_FILE          is export;
our $G_TYPE_MARKUP_PARSE_CONTEXT is export;
our $G_TYPE_MATCH_INFO           is export;
our $G_TYPE_OPTION_GROUP         is export;
our $G_TYPE_POLLFD               is export;
our $G_TYPE_PTR_ARRAY            is export;
our $G_TYPE_REGEX                is export;
our $G_TYPE_SOURCE               is export;
our $G_TYPE_STRV                 is export;
our $G_TYPE_THREAD               is export;
our $G_TYPE_TIME_ZONE            is export;
our $G_TYPE_VARIANT_BUILDER      is export;
our $G_TYPE_VARIANT_DICT         is export;
our $G_TYPE_VARIANT              is export;
our $G_TYPE_VARIANT_TYPE         is export;

INIT {
  $G_TYPE_ARRAY                = get_unstable_type( &g_array_get_type );
  $G_TYPE_BYTE_ARRAY           = get_unstable_type( &g_byte_array_get_type );
  $G_TYPE_BYTES                = get_unstable_type( &g_bytes_get_type );
  $G_TYPE_CHECKSUM             = get_unstable_type( &g_checksum_get_type );
  $G_TYPE_DATE                 = get_unstable_type( &g_date_get_type );
  $G_TYPE_DATE_TIME            = get_unstable_type( &g_date_time_get_type );
  $G_TYPE_ERROR                = get_unstable_type( &g_error_get_type );
  $G_TYPE_GSTRING              = get_unstable_type( &g_gstring_get_type );
  $G_TYPE_HASH_TABLE           = get_unstable_type( &g_hash_table_get_type );
  $G_TYPE_iO_CHANNEL           = get_unstable_type( &g_io_channel_get_type );
  $G_TYPE_IO_CONDITION         = get_unstable_type( &g_io_condition_get_type );
  $G_TYPE_KEY_FILE             = get_unstable_type( &g_key_file_get_type );
  $G_TYPE_MAIN_CONTEXT         = get_unstable_type( &g_main_context_get_type );
  $G_TYPE_MAIN_LOOP            = get_unstable_type( &g_main_loop_get_type );
  $G_TYPE_MAPPED_FILE          = get_unstable_type( &g_mapped_file_get_type );
  $G_TYPE_MARKUP_PARSE_CONTEXT = get_unstable_type( &g_markup_parse_context_get_type );
  $G_TYPE_MATCH_INFO           = get_unstable_type( &g_match_info_get_type );
  $G_TYPE_OPTION_GROUP         = get_unstable_type( &g_option_group_get_type );
  $G_TYPE_POLLFD               = get_unstable_type( &g_pollfd_get_type );
  $G_TYPE_PTR_ARRAY            = get_unstable_type( &g_ptr_array_get_type );
  $G_TYPE_REGEX                = get_unstable_type( &g_regex_get_type );
  $G_TYPE_SOURCE               = get_unstable_type( &g_source_get_type );
  $G_TYPE_STRV                 = get_unstable_type( &g_strv_get_type );
  $G_TYPE_THREAD               = get_unstable_type( &g_thread_get_type );
  $G_TYPE_TIME_ZONE            = get_unstable_type( &g_time_zone_get_type );
  $G_TYPE_VARIANT_BUILDER      = get_unstable_type( &g_variant_builder_get_type );
  $G_TYPE_VARIANT_DICT         = get_unstable_type( &g_variant_dict_get_type );
  # $G_TYPE_VARIANT            = get_unstable_type( &g_variant_get_gtype );
  $G_TYPE_VARIANT_TYPE         = get_unstable_type( &g_variant_type_get_gtype );
}
