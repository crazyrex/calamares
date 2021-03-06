#! /bin/sh
#
# Travis CI script for use on every-commit:
#  - build and install Calamares
#
test -n "$BUILDDIR" || { echo "! \$BUILDDIR not set" ; exit 1 ; }
test -n "$SRCDIR" || { echo "! \$SRCDIR not set" ; exit 1 ; }

test -d $BUILDDIR || { echo "! $BUILDDIR not a directory" ; exit 1 ; }
test -d $SRCDIR || { echo "! $SRCDIR not a directory" ; exit 1 ; }
test -f $SRCDIR/CMakeLists.txt || { echo "! Missing $SRCDIR/CMakeLists.txt" ; exit 1 ; }

cd $BUILDDIR || exit 1

echo "###"
echo "### cmake $CMAKE_ARGS $SRCDIR"
echo "###"
cmake $CMAKE_ARGS $SRCDIR || { echo "! CMake failed" ; exit 1 ; }

echo -e "###\n### make\n###"
make -j2 || { make -j1 VERBOSE=1 ; echo "! Make failed" ; exit 1 ; }

echo -e "###\n### make install\n###"

install_debugging() {
	ls -la $( find "$1" -type f -name '*.so' )
}

echo "# System status"
df -h

echo "# Build results"
install_debugging "$BUILDDIR"

echo "# Install"
DESTDIR=/build/INSTALL_ROOT
mkdir -p "$DESTDIR"

if make install VERBOSE=1 DESTDIR="$DESTDIR" ;
then
	echo "# .. install OK"
	result=true
else
	echo "# .. install failed"
	result=false
fi

echo "# System status"
df -h

echo "# Install results"
install_debugging "$DESTDIR"

$result || { echo "! Install failed" ; exit 1 ; } # Result of make install, above
