CC=gcc
LD=gcc
CFLAGS=-fPIC -I/usr/local/curl/include
LIBS=-L/usr/local/curl/lib -lcurl
LDFLAGS=-shared
OBJECTS=client.o auth.o
PREFIX=/usr/local

libplugauth.so : $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o libplugauth.so $(LIBS)

%.o : %.c plugauth.h plugauth_private.h
	$(CC) $(CFLAGS) -c $< -o $@

install : libplugauth.so libplugauth.pc.tmpl
	mkdir -p $(DESTDIR)$(PREFIX)/lib/pkgconfig
	mkdir -p $(DESTDIR)$(PREFIX)/include
	install libplugauth.so $(DESTDIR)$(PREFIX)/lib/libplugauth.so
	install plugauth.h $(DESTDIR)$(PREFIX)/include/plugauth.h
	perl -pe 's/PLUGAUTH_PREFIX/$$ENV{PREFIX}/g' libplugauth.pc.tmpl > $(DESTDIR)$(PREFIX)/lib/pkgconfig/libplugauth.pc

clean:
	rm -f *.o *.so
