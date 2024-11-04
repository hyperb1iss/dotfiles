# Java version switching aliases
# Assumes JDKs are installed in /usr/lib/jvm/
# Add to your .bashrc or .zshrc

# Function to switch Java version
function setjdk() {
    if [ $# -ne 1 ]; then
        echo "Usage: setjdk <version>"
        echo "Available versions:"
        ls -1 /usr/lib/jvm/ | grep -E "java-[0-9]+-openjdk-amd64|java-[0-9]+-oracle"
        return 1
    fi

    local version=$1
    local java_home

    case "$version" in
        8)
            java_home="/usr/lib/jvm/java-8-openjdk-amd64"
            ;;
        11)
            java_home="/usr/lib/jvm/java-11-openjdk-amd64"
            ;;
        17)
            java_home="/usr/lib/jvm/java-17-openjdk-amd64"
            ;;
        21)
            java_home="/usr/lib/jvm/java-21-openjdk-amd64"
            ;;
        *)
            echo "Unsupported Java version. Available versions: 8, 11, 17, 21"
            return 1
            ;;
    esac

    if [ ! -d "$java_home" ]; then
        echo "Error: Java $version is not installed at $java_home"
        return 1
    fi

    export JAVA_HOME="$java_home"
    export PATH="$JAVA_HOME/bin:$(echo $PATH | sed "s|/usr/lib/jvm/[^/]*/bin:||g")"

    echo "Switched to Java $version"
    java -version
}

# Convenient aliases for different Java versions
alias java8="setjdk 8"
alias java11="setjdk 11" 
alias java17="setjdk 17"
alias java21="setjdk 21"

# Add alias to list available versions
alias javalist="ls -1 /usr/lib/jvm/ | grep -E 'java-[0-9]+-openjdk-amd64|java-[0-9]+-oracle'"

