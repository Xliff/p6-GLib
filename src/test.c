#include <glib-object.h>

void main (int argc, char **argv) {
	printf("From src: %ld\n", 20 << 2);
	printf("GObject type: %ld\n", g_object_get_type() );
	printf("GObjectClass: %ld\n", sizeof(GObjectClass));
	printf("GTypeClass: %ld\n", sizeof(GTypeClass));
}
