#include <glib.h>
#include <glib-object.h>
#include <gio/gio.h>
#include <stdio.h>

void main (int argc, char **argv) {
	printf("From src: %ld\n", (long)(20 << 2));
	printf("GObjectPrivate size: %ld\n", sizeof(GOutputStream));
	printf("GObject type: %ld\n", g_object_get_type() );
	printf("GObjectClass: %ld\n", sizeof(GObjectClass));
	printf("GTypeClass: %ld\n", sizeof(GTypeClass));
}
