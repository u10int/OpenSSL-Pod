Pod::Spec.new do |s|
  s.name            = "OpenSSL"
  s.version         = "1.1.006"
  s.summary         = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in Mac OS and gone in iOS, this spec gives your project non-deprecated OpenSSL support."
  s.author          = "OpenSSL Project <openssl-dev@openssl.org>"

  s.homepage        = "https://github.com/FredericJacobs/OpenSSL-Pod"
  s.source          = { :http => "https://openssl.org/source/openssl-1.1.0f.tar.gz", :sha256 => "12f746f3f2493b2f39da7ecf63d7ee19c6ac9ec6a4fcd8c229da8a522cb12765"}
  s.source_files    = "opensslIncludes/openssl/*.h"
  s.header_dir      = "openssl"
  s.license         = { :type => 'OpenSSL (OpenSSL/SSLeay)', :file => 'LICENSE' }

  s.ios.deployment_target   = "8.0"
  s.ios.public_header_files = "opensslIncludes/openssl/*.h"
  s.ios.vendored_libraries  = "lib/libcrypto.a", "lib/libssl.a"

  s.libraries             = 'crypto', 'ssl'
  s.requires_arc          = false
  s.prepare_command = <<-CMD
    OPENSSL_VERSION="1.1.0f"
    SDKVERSION=`xcrun --sdk iphoneos --show-sdk-version 2> /dev/null`
    MIN_SDK_VERSION_FLAG="-miphoneos-version-min=8.0"

    BASEPATH="${PWD}"
    BUILD_ROOT="/tmp/openssl-pod"
    ARCHS="i386 x86_64 armv7 armv7s arm64"
    DEVELOPER=`xcode-select -print-path`
    OUTPUT_DIR="${BUILD_ROOT}/output"

    mkdir -p "${OUTPUT_DIR}"

    cp "file.tgz" "${BUILD_ROOT}/file.tgz"
    cd "${BUILD_ROOT}"
    tar -xzf file.tgz
    SRC_DIR="openssl-${OPENSSL_VERSION}"
    cd $SRC_DIR

    echo "Building OpenSSL. This will take a while..."
    for ARCH in ${ARCHS}
    do
      CONFIGURE_FOR="iphoneos-cross"

      if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ] ;
      then
        PLATFORM="iPhoneSimulator"
        if [ "${ARCH}" == "x86_64" ] ;
        then
          CONFIGURE_FOR="darwin64-x86_64-cc"
        fi
      else
        sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
        PLATFORM="iPhoneOS"
      fi

      export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
      export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"

      echo "Building openssl-${OPENSSL_VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
      echo "Please stand by..."

      export CC="${DEVELOPER}/usr/bin/gcc -arch ${ARCH} ${MIN_SDK_VERSION_FLAG}"

      ARCH_OUTPUT_DIR="${OUTPUT_DIR}/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
      mkdir -p "${ARCH_OUTPUT_DIR}"
      SSL_BUILD_LOG="${ARCH_OUTPUT_DIR}/build-openssl-${OPENSSL_VERSION}.log"

      ./Configure ${CONFIGURE_FOR} --prefix="${ARCH_OUTPUT_DIR}" --openssldir="${ARCH_OUTPUT_DIR}" > "${SSL_BUILD_LOG}" 2>&1
      sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} !" "Makefile"

      make build_libs >> "${SSL_BUILD_LOG}" 2>&1
      make install >> "${SSL_BUILD_LOG}" 2>&1
      make clean >> "${SSL_BUILD_LOG}" 2>&1

      if [ !-e "${ARCH_OUTPUT_DIR}/lib/libssl.a" ]
      then
        echo "Failed to build ${ARCH_OUTPUT_DIR}/lib/libssl.a"
        echo "See ${SSL_BUILD_LOG} for details"
        exit 1
      fi
      LIBSSL_ACCUM="${LIBSSL_ACCUM} ${ARCH_OUTPUT_DIR}/lib/libssl.a"

      if [ !-e "${ARCH_OUTPUT_DIR}/lib/libcrypto.a" ]
      then
        echo "Failed to build ${ARCH_OUTPUT_DIR}/lib/libssl.a"
        echo "See ${SSL_BUILD_LOG} for details"
        exit 1
      fi
      LIBCRYPTO_ACCUM="${LIBCRYPTO_ACCUM} ${ARCH_OUTPUT_DIR}/lib/libcrypto.a"
    done

    echo "Creating fat library..."
    rm -rf "${BASEPATH}/lib/"
    mkdir -p "${BASEPATH}/lib/"
    lipo -create ${LIBSSL_ACCUM}    -output "${BASEPATH}/lib/libssl.a"
    lipo -create ${LIBCRYPTO_ACCUM} -output "${BASEPATH}/lib/libcrypto.a"

    echo "Copying headers..."
    rm -rf "${BASEPATH}/opensslIncludes/"
    mkdir -p "${BASEPATH}/opensslIncludes/"
    cp -RL "${BUILD_ROOT}/${SRC_DIR}/include/openssl" "${BASEPATH}/opensslIncludes/"

    cd "${BASEPATH}"
    echo "Building done."

    echo "Cleaning up..."
    rm -rf "${BUILD_ROOT}"
    echo "Done."
  CMD

end
