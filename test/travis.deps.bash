#!/usr/bin/env bash
#
# This script installs and configures the dependencies for the sbt-extras
# Author: Kevin Brightwell (Github: Nava2)

declare OS_NAME

case `uname` in 
    Darwin)     OS_NAME="osx"    ;;
    Linux)      OS_NAME="linux"  ;;
esac

if env | grep -qE '^(?:TRAVIS|CI)='; then
#    We're on Travis, intialize variables:
    echo "Detected CI Build -> CI=${CI}"

else
#   We're building locally
    echo "This script is meant to be run by Travis-CI services."

    # exit 1
fi

echo "Building on: ${OS_NAME}"

install_os_deps() {
    # Install all of the OS specific OS dependencies
    local JDK_VERSION_LEVEL=${JDK_VERSION:(-1)}

    echo "Attempting to use Java: ${JDK_VERSION}"

    case ${OS_NAME} in
        osx)
            if [[ ${JDK_VERSION} == openjdk* ]] ; then
                echo "OpenJDK is not supported on OSX, defaulting to oraclejdk${JDK_VERSION_LEVEL}"
                export JDK_VERSION=oraclejdk${JDK_VERSION_LEVEL}
            fi
            
            # Install the correct version of Java:

            case ${JDK_VERSION_LEVEL} in
                8)
                    CASK_PKG=caskroom/cask;
                    JAVA_PKG="java"
                    ;;
                7|9)
                    CASK_PKG=caskroom/versions;
                    JAVA_PKG="java${JDK_VERSION_LEVEL}";
                    #echo "Invalid Java Version, ${JDK_VERSION}"
                    # exit 1
                    ;;
            esac

            echo "Installing ${JDK_VERSION} from: ${CASK_PKG}:${JAVA_PKG}"

            brew tap ${CASK_PKG}

            echo "brew update ..." ; brew update > /dev/null #; brew doctor; brew update

            brew cask install ${JAVA_PKG}
        ;;

        linux)
            
        ;;
    esac

    java -version
}

install_os_deps