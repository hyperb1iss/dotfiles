# Custom functions for various tasks

# Function to pull files from an Android device
function apull() {
    for ARG in $@; do
        for FILE in "$(adb shell ls $ARG)"; do
            echo $FILE
            adb pull "$FILE"
        done
    done
}

# Function to push files to an Android device
function apush() {
    if [ -z "$OUT" ]; then
        echo "OUT is not set!"
    else
        adb push "$1" "$OUT"
    fi
}

# Shortcut to change directory to Windows User folder (WSL-specific)
W=/mnt/c/Users/Stefanie
function cdw() {
    cd $W
}

