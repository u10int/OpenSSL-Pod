OpenSSL-Pod
===========

### Version numbering

Because OpenSSL's version numbers are not compatible with the CocoaPods version numbering, we will agree on the following.

OpenSSL version: `A.B.CD` will become `A.B.C*100 + place of D in the alphabet` (indexed from 1).

Example: OpenSSL 1.0.1h => OpenSSL 1.0.108
Example: OpenSSL 1.1.0a => OpenSSL 1.1.001

### Note for Development Podders

If you are referencing this as a development pod, e.g. if your Podfile
looks like:

    pod 'OpenSSL', path: '../OpenSSL-Pod/1.1.006'

You cannot simply run `pod install`. You will have to manually download
and compare the source.

   curl https://openssl.org/source/openssl-1.1.0f.tar.gz
   shasum -a256 openssl-1.1.0f.tar.gz
