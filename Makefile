CC=gcc
AR=ar
LD=gcc
CFLAGS=-fPIC -I/usr/local/curl/include
LIBS=-L/usr/local/curl/lib -lcurl
LDFLAGS=-shared
OBJECTS=client.o auth.o version.o
PREFIX=/usr/local
RANLIB=ranlib
PLUGAUTH_VERSION=001

all : libplugauth.so libplugauth.a libplugauth-client

libplugauth-client : main.o plugauth.h
	$(CC) -o libplugauth-client main.o -L. -lplugauth

libplugauth.a : $(OBJECTS)
	$(AR) rcs libplugauth.a $(OBJECTS)
	$(RANLIB) libplugauth.a

libplugauth.so : $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o libplugauth.so $(LIBS)

%.o : %.c plugauth.h plugauth_private.h
	$(CC) $(CFLAGS) -DPLUGAUTH_VERSION=$(PLUGAUTH_VERSION) -c $< -o $@

install : libplugauth.so libplugauth.pc.tmpl
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/lib/pkgconfig
	mkdir -p $(DESTDIR)$(PREFIX)/include
	install -m 0755 libplugauth-client $(DESTDIR)$(PREFIX)/bin/libplugauth-client
	install -m 0644 libplugauth.a  $(DESTDIR)$(PREFIX)/lib/libplugauth.a
	install -m 0755 libplugauth.so $(DESTDIR)$(PREFIX)/lib/libplugauth.so
	install -m 0644 plugauth.h $(DESTDIR)$(PREFIX)/include/plugauth.h
	perl -pe 's/PLUGAUTH_PREFIX/$$ENV{PREFIX}/g' libplugauth.pc.tmpl > $(DESTDIR)$(PREFIX)/lib/pkgconfig/libplugauth.pc

clean distclean:
	rm -f *.o *.so *.a libplugauth-client
	rm -rf destdir

rpm: all
	rm -rf ./destdir
	$(MAKE) install PREFIX=/util DESTDIR=./destdir
