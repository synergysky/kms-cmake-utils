#.rst:
# CommonBuildFlags
# ----------------
#
# Set common compiler flags used to build all Kurento modules.
# This module provides a single function that will set all compiler flags
# to a set of well tested values. The defined flags will also enforce a set
# of common rules which are intended to maintain a good level of security and
# code quality. These are:
# - Language selection: C11 and C++11 with GNU extensions.
# - Warnings are forbidden during development (but allowed for production):
#   '-Werror' is used for Debug builds.
#   Developers can opt-out of this rule, setting '-Wno-error=<WarningName>'.
#   For example:
#       set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-error=unused-function")
# - Debian security hardening best practices:
#   - Format string checks.
#   - Fortify source functions (check usages of memcpy, strcpy, etc.)
#   - Stack protection.
#   - Read-only relocations.
# - Extra hardening options are also enabled:
#   - Position Independent Executables; this allows to take advantage of the
#     Address Space Layout Randomization (ASLR) provided by the Linux kernel.
#   - Immediate binding.
#
# Function:
# - common_buildflags_set()
#
# See also:
# - https://wiki.debian.org/HardeningWalkthrough

#=============================================================================
# (C) Copyright 2018 Kurento (http://kurento.org/)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================

function(common_buildflags_set)
  include(DpkgBuildFlags)

  # The environment variable 'DEB_BUILD_MAINT_OPTIONS' is used to instruct
  # Debhelper to use all available security hardening mechanisms.
  set(ENV{DEB_BUILD_MAINT_OPTIONS} "hardening=+all")
  dpkg_buildflags_get_cflags(DPKG_CFLAGS)
  dpkg_buildflags_get_cxxflags(DPKG_CXXFLAGS)
  dpkg_buildflags_get_ldflags(DPKG_LDFLAGS)

  # General flags, covering all build configurations
  set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -std=gnu11   -Wall -pthread" PARENT_SCOPE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -Wall -pthread" PARENT_SCOPE)

  # Debug builds
  #
  # FIXME Ideal is '-Og' but a bug in GCC prevents this, causing
  #       "may be used uninitialized" errors:
  #       https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58455
  #       Affects GCC 5.4.0 (Ubuntu 16.04 "Xenial")
  set(CMAKE_C_FLAGS_DEBUG   "${DPKG_CFLAGS}   -Werror -g -O0" PARENT_SCOPE)
  set(CMAKE_CXX_FLAGS_DEBUG "${DPKG_CXXFLAGS} -Werror -g -O0" PARENT_SCOPE)
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${DPKG_LDFLAGS}" PARENT_SCOPE)
  set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "${DPKG_LDFLAGS}" PARENT_SCOPE)
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG    "${DPKG_LDFLAGS}" PARENT_SCOPE)

  # Release builds
  #
  # CMake adds '-O3' by default for the Release build type, but here we want
  # to change that to '-O2', which is the default used by Debian toolchain.
  set(CMAKE_C_FLAGS_RELEASE   "${DPKG_CFLAGS}   -DNDEBUG -O2" PARENT_SCOPE)
  set(CMAKE_CXX_FLAGS_RELEASE "${DPKG_CXXFLAGS} -DNDEBUG -O2" PARENT_SCOPE)
  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${DPKG_LDFLAGS}" PARENT_SCOPE)
  set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${DPKG_LDFLAGS}" PARENT_SCOPE)
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE    "${DPKG_LDFLAGS}" PARENT_SCOPE)

  # Build all targets with '-fPIC'/'-fPIE' by default, including static libs
  set(CMAKE_POSITION_INDEPENDENT_CODE ON PARENT_SCOPE)

  # FIXME CMake doesn't link executables with '-pie', even if
  #       CMAKE_POSITION_INDEPENDENT_CODE is ON.
  #       See: CMake issue #14983 (https://gitlab.kitware.com/cmake/cmake/issues/14983)
  #       Affects CMake 3.5.1 (Ubuntu 16.04 "Xenial")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pie" PARENT_SCOPE)
endfunction()


# Debug: Print all variables
function(common_buildflags_print)
  message("CMAKE_C_FLAGS:             ${CMAKE_C_FLAGS}")
  message("CMAKE_CXX_FLAGS:           ${CMAKE_CXX_FLAGS}")
  message("CMAKE_STATIC_LINKER_FLAGS: ${CMAKE_STATIC_LINKER_FLAGS}")
  message("CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}")
  message("CMAKE_MODULE_LINKER_FLAGS: ${CMAKE_MODULE_LINKER_FLAGS}")
  message("CMAKE_EXE_LINKER_FLAGS:    ${CMAKE_EXE_LINKER_FLAGS}")

  message("CMAKE_C_FLAGS_DEBUG:             ${CMAKE_C_FLAGS_DEBUG}")
  message("CMAKE_CXX_FLAGS_DEBUG:           ${CMAKE_CXX_FLAGS_DEBUG}")
  message("CMAKE_STATIC_LINKER_FLAGS_DEBUG: ${CMAKE_STATIC_LINKER_FLAGS_DEBUG}")
  message("CMAKE_SHARED_LINKER_FLAGS_DEBUG: ${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
  message("CMAKE_MODULE_LINKER_FLAGS_DEBUG: ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  message("CMAKE_EXE_LINKER_FLAGS_DEBUG:    ${CMAKE_EXE_LINKER_FLAGS_DEBUG}")

  message("CMAKE_C_FLAGS_RELEASE:             ${CMAKE_C_FLAGS_RELEASE}")
  message("CMAKE_CXX_FLAGS_RELEASE:           ${CMAKE_CXX_FLAGS_RELEASE}")
  message("CMAKE_STATIC_LINKER_FLAGS_RELEASE: ${CMAKE_STATIC_LINKER_FLAGS_RELEASE}")
  message("CMAKE_SHARED_LINKER_FLAGS_RELEASE: ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
  message("CMAKE_MODULE_LINKER_FLAGS_RELEASE: ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
  message("CMAKE_EXE_LINKER_FLAGS_RELEASE:    ${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
endfunction()
