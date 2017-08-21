OpenSSL-Pod
===========


### Version numbering 

Because OpenSSL's version numbers are not compatible with the CocoaPods version numbering, we will agree on the following.

OpenSSL version: A.B.CD will become A.B.C*100 + place of D in the alphabet (indexed by 1).

Example: OpenSSL 1.0.1h => OpenSSL 1.0.108

### Keeping the pod up-to-date

Update the podspec to reference the latest 1.0.* tarball and sha256
checksum from https://www.openssl.org/source/

**note** the 1.1.\* series has some changed that aren't compatible with
our existing build script.

**note** Most cocoapods podspecs reside within the same repository as
the source that they build. The `source` option in your podspec
references an external source location; However, using `source` doesn't
play nicely with development pods or referencing a pod via git URL.

In order to test the development pod download, you'll need to fetch and
rename the source yourself, before running `pod install`

    cd $MY_PROJECT
    edit Podfile

Update Podfile to reference your local podspec with a line like:

    pod 'OpenSSL', path: '~/src/OpenSSL-Pod'

Then you have to manually fetch the external source:

    cd ~/src/OpenSSL-Pod
    curl -o file.tgz https://www.openssl.org/source/openssl-1.0.2l.tar.gz

Now you can run pod install as normal

    cd $MY_PROJECT
    pod install

Again, this is only required when building OpenSSL as a development pod,
when installing from cocoapods like normal, the external source will be
fetched for you.
