use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::GList;
use GLib::Raw::GenericList;

use GLib::Roles::ListData;
use GLib::Roles::PointerBasedList;

# See if this will work properly:
# - Move ALL data related routines to a ListData parameterized role.
# - Have raw_data method implemented in client classes that return the pointer
#   attribute.
class GLib::GList {
  also does GLib::Roles::PointerBasedList;
  #also does Positional;
  #also does Iterator;

  has GList $!list is implementor handles<p>;
  has GList $!cur;

  submethod BUILD(:$list) {
    # die 'Must use a type object for $type when creating a GLib::GSList'
    #   if $type.defined;

    $!dirty = True;
    $!cur = $!list = $list;

    # No longer necessary due to GLib::Roles::ListData
    #$!type := $type;

    # See NOTE.
    #
    # while $!cur.defined {
    #   @!nat.push: self.data;
    #   $!cur .= next;
    # }
    # $!cur = $!list;
  }

  submethod DESTROY {
    #self.free;
  }

  # Left active, but see NOTE.
  has $.dirty;

  method first {
    #g_list_first($!list);
    $!cur = $!list;
  }

  # Need a current pointer.
  method next {
    $!cur .= next;
  }

  method prev {
    $!cur .=  prev;
  }

  #method cur { ... }

  # Since GSList is binary compatible with GList and is being used as an
  # alternative until GSList is stable...
  subset ValidListTypes where
    GLib::Raw::Structs::GSList | GLib::Raw::Structs::GList;

  # multi method new (GList $list) {
  #   $list ?? self.bless(:$list) !! Nil;
  # }
  multi method new (ValidListTypes $list is copy) {
    return Nil unless $list;

    # While we are using GList as an alternative for GSList;
    $list = cast(GList, $list) unless $list ~~ GList;

    self.bless(:$list);
  }
  multi method new (
    @list,
    :$signed       = False,
    :$double       = False,
    :$direct       = False,
    :$encoding     = 'utf8',
    :type(:$typed)
  ) {
    my $l = GLib::GList.new;

    # We already start with a List with 1 NULL data element. We must
    # fill THAT first, before we start appending, so we need to distinguish
    # it.
    self.addToList(
      $l,
      @list,
      :$signed,
      :$double,
      :$direct,
      :$encoding,
      :$typed
    );

    $l;
  }
  multi method new {
    my $list = g_list_alloc();

    $list ?? self.bless(:$list) !! Nil;
  }

  method GLib::Raw::Structs::GList
    is also<GList>
  { $!list }

  method current_node
    is also<
      current-node
      cur
      current
      node
    >
  { $!cur }

  method cleaned {
    $!dirty = False;
  }

  # NOTE -- NOTE -- NOTE -- NOTE -- NOTE -- NOTE -- NOTE -- NOTE -- NOTE
  # Probably better to finish work on GLib::Roles::ListData role and move
  # the Array backing to it. Until that decision has been made, this code
  # has been deactivated.
  #
  # has @!nat
  #   handles
  #   «pull-one iterator elems AT-POS EXISTS-POS join :p6sort('sort')»;
  #
  # method !rebuild {
  #   my GLib::Raw::Structs::GList $l;
  #
  #   @!nat = ();
  #   loop ($l = self.first; $l != GList; $l = $l.next) {
  #     @!nat.push: self.data($l);
  #   }
  #   @!nat;
  # }

  method !_data is rw {
    $!cur.data;
  }

  multi method append (@data) {
    self.append($_) for @data;
    self
  }
  multi method append ($data) {
    samewith( toPointer($data) );
  }
  multi method append (Pointer $data) {
    # Insure works for newly created list with no contents!
    if $!list.data {
      g_list_append($!list, $data);
      $!dirty = True;
    } else {
      $!list.data = $data;
    }
    # Allow chaining .append!
    self
  }
  multi method append (GLib::GList:U: $list is copy, Pointer $data) {
    $list = do if $list.^lookup('GList') -> $m {
      $m($list)
    } else {
      $list = GList.new;
    }

    g_list_append($list, $data);
  }

  multi method concat (
    GLib::GList:U:
    GLib::Raw::Structs::GList $list1,
    GLib::Raw::Structs::GList $list2
  ) {
    g_list_concat($list1, $list2);
  }
  multi method concat (GLib::Raw::Structs::GList() $list2) {
    my $list = g_list_concat($!list, $list2);

    $!dirty = True;
    $!list = $list;
  }

  method copy {
    my $l = g_list_copy($!list);

    $l ?? self.bless( list => $l ) !! Nil;
  }

  method copy_deep (
            &func,
    Pointer $user_data = Pointer
  )
    is also<copy-deep>
  {
    self.bless(
      #type => $!type,
      list => g_list_copy_deep($!list, &func, $user_data)
    );
  }

  method delete_link (GLib::Raw::Structs::GList() $link)
    is also<delete-link>
  {
    my $list = g_list_delete_link($!list, $link);
    $!dirty = True;
    $!list = $list;
  }

  method find (Pointer $data) {
    g_list_find($!list, $data);
  }

  method find_custom (Pointer $data, &func)
    is also<find-custom>
  {
    g_list_find_custom($!list, $data, &func);
  }

  method foreach (
            &func,
    Pointer $user_data = Pointer
  ) {
    g_list_foreach($!list, &func, $user_data);
  }

  method free {
    g_list_free($!list);
  }

  # Aliases with numbers after the dash are still a Bad Idea
  method free_1 is also<free1> {
    g_list_free_1($!list);
  }

  method free_full (&free_func) is also<free-full> {
    my &func := &free_func // &g_destroy_none;
    g_list_free_full($!list, &func);
  }

  method index (Pointer $data) {
    g_list_index($!list, $data);
  }

  method insert (Pointer $data, Int() $position) {
    my gint $p = $position;
    my $list = g_list_insert($!list, $data, $p);

    $!dirty = True;
    $!list = $list;
  }

  method insert_before (GLib::Raw::Structs::GList() $sibling, Pointer $data)
    is also<insert-before>
  {
    my $list = g_list_insert_before($!list, $sibling, $data);

    $!dirty = True;
    $!list = $list;
  }

  method insert_sorted (Pointer $data, &func)
    is also<insert-sorted>
  {
    my $list = g_list_insert_sorted($!list, $data, &func);
    $!dirty = True;
    $!list = $list;
  }

  method insert_sorted_with_data (
    Pointer $data,
            &func,
    Pointer $user_data = Pointer
  )
    is also<insert-sorted-with-data>
  {
    my $list = g_list_insert_sorted_with_data(
      $!list, $data, &func, $user_data
    );
    $!dirty = True;
    $!list = $list;
  }

  method last {
    g_list_last($!list);
  }

  method length {
    g_list_length($!list);
  }

  method nth (Int() $n) {
    my guint $nn = $n;

    g_list_nth($!list, $nn);
  }

  method nth_data (Int() $n)
    is also<nth-data>
  {
    my guint $nn = $n;

    g_list_nth_data($!list, $nn);
  }

  method nth_prev (Int() $n) is also<nth-prev> {
    my guint $nn = $n;

    g_list_nth_prev($!list, $nn);
  }

  method position (GLib::Raw::Structs::GList() $llink) {
    g_list_position($!list, $llink);
  }

  multi method prepend (Pointer $data) {
    my $list = GLib::GList.prepend($!list, $data);

    $!dirty = True;
    $!list = $list;
  }
  multi method prepend (GLib::GList:U: $list is copy, Pointer $data) {
    $list = do if $list.^lookup('GList') -> $m {
      $m($list)
    } else {
      $list = GList.new;
    }

    g_list_prepend($list, $data);
  }

  method remove (Pointer $data) {
    my $list = g_list_remove($!list, $data);

    $!dirty = True;
    $!list = $list;
  }

  method remove_all (Pointer $data) is also<remove-all> {
    g_list_remove_all($!list, $data);

    $!dirty = True;
    #!nat = ();
  }

  method remove_link (GLib::Raw::Structs::GList() $llink)
    is also<remove-link>
  {
    my $list = g_list_remove_link($!list, $llink);

    $!dirty = True;
    $!list = $list;
  }

  method reverse {
    my $list = g_list_reverse($!list);

    $!dirty = True;
    $!list = $list;
  }

  method sort (&compare_func) {
    $!list = g_list_sort($!list, &compare_func);
    $!dirty = True;
  }

  method sort_with_data (&compare_func, Pointer $user_data = Pointer)
    is also<sort-with-data>
  {
    $!list = g_list_sort_with_data($!list, &compare_func, $user_data);
    $!dirty = True;
  }

}

sub returnGList (
  $gl     is copy,
  $glist,
  $raw,
  $T      =  Str,
  $O?,
  :$seq   =  True,
  :$ref   =  False;
)
  is export
{
  returnGenericList(GLib::GList, $gl, $glist, $raw, $T, $O, :$seq, :$ref);
}

sub returnGListObjects ( $gl, $T = Str, $O?, :$seq = True ) is export {
  returnGList($gl, False, False, $T, $O, :$seq);
}
