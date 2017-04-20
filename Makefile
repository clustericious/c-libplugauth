CC=gcc
AR=ar
LD=gcc
CFLAGS=-fPIC -I/usr/local/curl/include
LIBS=-L/usr/local/curl/lib -lcurl
LDFLAGS=-shared
OBJECTS=client.o auth.o version.o
PREFIX=/usr/local
RANLIB=ranlib
PLUGAUTH_MAJOR=0
PLUGAUTH_MINOR=01
PLUGAUTH_VERSION=$(PLUGAUTH_MAJOR)$(PLUGAUTH_MINOR)
DIST_SOURCE=`git ls-files | grep -v ^.gitignore`

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

libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR).tar.gz :
	mkdir -p libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR)
	cp -a $(DIST_SOURCE) libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR)
	bsdtar zcvf libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR).tar.gz libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR)
	rm -rf libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR)

dist : libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR).tar.gz

acps-libplugauth.spec : acps-libplugauth.spec.tmpl
	env PLUGAUTH_VERSION=$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR) PLUGAUTH_RELEASE=$$((`arpm -qa | grep libplugauth | cut -d- -f3 | cut -d. -f1` + 1)) perl -pe 's/(PLUGAUTH_(?:VERSION|RELEASE))/$$ENV{$$1}/eg' acps-libplugauth.spec.tmpl > acps-libplugauth.spec

rpm : acps-libplugauth.spec libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR).tar.gz
	mkdir -p ~/rpmbuild/SOURCES
	cp -a libplugauth-$(PLUGAUTH_MAJOR).$(PLUGAUTH_MINOR).tar.gz ~/rpmbuild/SOURCES
	rpmbuild -bb acps-libplugauth.spec

clean distclean:
	rm -f *.o *.so *.a libplugauth-client acps-libplugauth.spec *.tar.gz
	rm -rf destdir
