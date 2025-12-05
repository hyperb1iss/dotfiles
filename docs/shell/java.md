# Java

_Version switching across platforms_

Java version management is a pain. These utilities make it tolerable across macOS, Arch, and Debian.

## Quick Switching

| Alias      | Command       | Description        |
| ---------- | ------------- | ------------------ |
| `java8`    | `setjdk 8`    | Switch to Java 8   |
| `java11`   | `setjdk 11`   | Switch to Java 11  |
| `java17`   | `setjdk 17`   | Switch to Java 17  |
| `java21`   | `setjdk 21`   | Switch to Java 21  |
| `javalist` | List versions | Show all available |

One command to switch Java versions. Works on macOS, Arch Linux, and Debian/Ubuntu.

## Functions

### `setjdk` — Switch Version

Platform-aware Java version switching:

```bash
setjdk 17
# Sets JAVA_HOME
# Updates PATH
# Works on macOS, Arch, Debian
```

Check with `java -version` after switching.

### `list_java_versions` — Available Versions

See what's installed:

```bash
javalist
# Shows all installed JDK versions
# Platform-specific output
```

## Platform-Specific Details

### macOS

Uses `/usr/libexec/java_home` for version management:

```bash
# List all Java versions
/usr/libexec/java_home -V

# Get path for specific version
/usr/libexec/java_home -v 17

# The setjdk function handles this automatically
```

Install Java versions with Homebrew:

```bash
brew install openjdk@17
brew install openjdk@21
```

### Arch Linux

Uses `archlinux-java` utility:

```bash
# Show available versions
archlinux-java status

# Switch (requires sudo)
sudo archlinux-java set java-17-openjdk

# The setjdk function handles this automatically
```

Install Java with pacman:

```bash
sudo pacman -S jdk17-openjdk
sudo pacman -S jdk21-openjdk
```

### Debian/Ubuntu

Uses `update-java-alternatives`:

```bash
# List available versions
update-java-alternatives -l

# Switch (requires sudo)
sudo update-java-alternatives -s java-17-openjdk-amd64

# The setjdk function handles this automatically
```

Install Java with apt:

```bash
sudo apt install openjdk-17-jdk
sudo apt install openjdk-21-jdk
```

## Gradle Integration

Gradle-specific utilities are in `sh/gradle.sh`:

| Function | Description          |
| -------- | -------------------- |
| `gtest`  | Run Gradle tests     |
| `grun`   | Run Gradle task      |
| `gclear` | Clean Gradle caches  |
| `gdeps`  | Show dependencies    |
| `gbuild` | Build module         |
| `gtasks` | List available tasks |

These work with the Gradle wrapper (`./gradlew`).

## Workflows

### Check Current Version

```bash
# See active Java version
java -version

# See JAVA_HOME
echo $JAVA_HOME

# List all available
javalist
```

### Switch for a Project

```bash
# Enter project
cd ~/projects/legacy-app

# Check what's available
javalist

# Switch to required version
java11  # or: setjdk 11

# Verify
java -version

# Build
./gradlew build
```

### Gradle Build

```bash
# Ensure correct Java version
java17

# Clean build
./gradlew clean build

# Run tests
./gradlew test

# Or with functions:
gbuild
gtest
```

### Managing Multiple Projects

```bash
# Project A needs Java 11
cd ~/projects/project-a
java11
./gradlew build

# Project B needs Java 17
cd ~/projects/project-b
java17
./gradlew build
```

Consider adding a `.java-version` file to projects and auto-switching on cd (similar to `.nvmrc` for Node).

## Troubleshooting

### JAVA_HOME Not Set

```bash
# Check current value
echo $JAVA_HOME

# If empty, use setjdk
setjdk 17

# Verify
echo $JAVA_HOME
```

### Wrong Version Active

```bash
# Check current
java -version

# See what's available
javalist

# Switch to correct one
setjdk 17
```

### Gradle Using Wrong Java

```bash
# Gradle uses JAVA_HOME
# Switch Java first
java17

# Then run Gradle
./gradlew build

# Or specify explicitly
JAVA_HOME=/path/to/jdk17 ./gradlew build
```

## Pro Tips

**One version per project**: Different projects need different Java versions. Get comfortable switching.

**macOS Homebrew**: Use `brew install openjdk@<version>` for easy management.

**LTS versions**: Stick to LTS releases (11, 17, 21) unless you need specific features.

**Gradle wrapper**: Always use `./gradlew` instead of global `gradle`. Ensures consistent builds.

**JAVA_HOME in scripts**: Shell scripts should check JAVA_HOME. Use `setjdk` before running them.

**Auto-switch on cd**: Consider adding project-specific Java version detection to your shell (like NVM's auto-switch).

**Keep it simple**: Don't install every Java version. Install what you actually use—usually just one or two.
