#!/usr/bin/env bash
#
# This script installs and configures the dependencies for the sbt-extras
# Author: Kevin Brightwell (Github: Nava2)


# Find $os_name
declare os_name
case `uname` in 
    Darwin)     os_name="osx"    ;;
    Linux)      os_name="linux"  ;;
esac
echo "Building on: ${os_name}"

# Check for CI variables
if ! env | grep -qE '^(?:TRAVIS|CI)='; then
    echo "WARNING: This script is meant to be run by Travis-CI services."
fi

install_os_deps() {
    # Install all of the OS specific OS dependencies
    local jdk_version_level=${JDK_VERSION:(-1)}

    echo "Attempting to use Java: ${JDK_VERSION}"

    case ${os_name} in
        osx)
            if [ -z "${JDK_VERSION}" ]; then
                echo "Error: On OSX, JDK_VERSION environment must be specified."
                echo "    Valid options: oraclejdk7 oraclejdk8 oraclejdk9 "
                echo "                   openjdk7 openjdk8"
                exit 1
            fi
            
            if [[ ${JDK_VERSION} == openjdk* ]] ; then
                echo "OpenJDK is not supported on osx, defaulting to oraclejdk${jdk_version_level}"
                export JDK_VERSION=oraclejdk${jdk_version_level}
            fi

            local cask_pkg java_pkg
            
            # Figure out the correct cask and package name homebrew:
            case ${jdk_version_level} in
                8)
                    cask_pkg="caskroom/cask"
                    java_pkg="java"
                    ;;

                7|9)
                    cask_pkg="caskroom/versions"
                    java_pkg="java${jdk_version_level}"
                    ;;
            esac

            echo "Installing ${JDK_VERSION} from: ${cask_pkg}:${java_pkg}"

            brew tap ${cask_pkg}

            echo "brew update ..." ; brew update > /dev/null # The `brew update` output is useless

            brew cask install ${java_pkg}
        ;;

        linux)
            # jdk_switcher is performed by Travis
        ;;
    esac

    java -version
}

install_os_deps
