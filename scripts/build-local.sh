#!/usr/bin/env sh
# Optimized build for the machine it runs on (macOS or Linux).
#
#   Release + CONTOUR_PRODUCTION_BUILD  -O3, link-time optimization, the platform's exploit
#                                      mitigations -- what the release packages are built with.
#   -mcpu=native / -march=native       code tuned for and limited to this CPU (the binary will
#                                      not run on an older one).
#   no tests, benchmarks or tools      nothing the terminal itself does not need.
#
# Usage: scripts/build-local.sh [extra cmake -D options]
#   BUILD_DIR   build directory (default: out/local)
#
# macOS: needs Homebrew qt, cmake and ninja. The result is out/local/src/contour/contour.app;
#        see scripts/install-local.sh to install it.
# Linux: needs Qt 6 (base, declarative, multimedia, shadertools, svg, wayland) development
#        packages, cmake, ninja and a C++23 compiler.
set -eu

src=$(cd "$(dirname "$0")/.." && pwd)
build=${BUILD_DIR:-$src/out/local}

case $(uname -s) in
    Darwin)
        # Apple clang names the CPU with -mcpu on arm64; -march=native is x86 spelling.
        cpu=-mcpu=native
        # Qt's FindWrapOpenGL falls back to "-framework AGL", which newer SDKs no longer ship;
        # point it at OpenGL.framework (already linked) so the link step finds a framework.
        set -- -DCMAKE_PREFIX_PATH="$(brew --prefix qt)" \
            -DWrapOpenGL_AGL="$(xcrun --show-sdk-path)/System/Library/Frameworks/OpenGL.framework" "$@"
        ;;
    *)
        cpu=-march=native
        ;;
esac

cmake -S "$src" -B "$build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCONTOUR_PRODUCTION_BUILD=ON \
    -DCMAKE_C_FLAGS="$cpu" \
    -DCMAKE_CXX_FLAGS="$cpu" \
    -DCMAKE_OBJC_FLAGS="$cpu" \
    -DCMAKE_OBJCXX_FLAGS="$cpu" \
    -DCONTOUR_TESTING=OFF \
    -DCONTOUR_VERIFY_STATE=OFF \
    -DLIBUNICODE_TESTING=OFF \
    -DCONTOUR_INSTALL_TOOLS=OFF \
    -DLIBTERMINAL_BUILD_BENCH_HEADLESS=OFF \
    -DVTHOST_BUILD_BENCH_LATENCY=OFF \
    -DCONTOUR_EXTENSIONS_BUNDLED=OFF \
    -DPEDANTIC_COMPILER=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    "$@"

cmake --build "$build"
