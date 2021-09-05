GTK_CFLAGS = $(shell pkg-config gobject-2.0 --cflags)
GTK_LIBS = $(shell pkg-config gobject-2.0 --libs)

all: key_file glib-support.so tree-helper.so

key_file: key_file.o
	gcc -o key_file.exe key_file.o $(GTK_LIBS)

key_file.o: key_file.c
	gcc -c key_file.c -o key_file.o $(GTK_CFLAGS)

glib-support.so: glib-support.c
	gcc glib-support.c $(GTK_CFLAGS) -shared -fPIC -o glib-support.so $(GTK_LIBS)

tree-helper.so: tree-helper.c
	gcc tree-helper.c -shared -fPIC -o tree-helper.so

clean:
	rm -rf *o key_file
	rm -rf *exe key_file
	rm -rf glib-support.so
	rm -rf tree-helper.so
