# gradle.sh
# Gradle utilities for Android development

# Skip entire module if not in full installation
is_minimal && return 0

# Run tests for a Gradle module
function gtest() {
  local module="${1:-.}"
  local variant="${2:-Debug}"
  local filter="$3"

  # Build command with proper test output formatting
  local cmd="./gradlew"
  cmd+=" ${module}:test${variant}"
  [[ -n "${filter}" ]] && cmd+=" --tests ${filter}"
  cmd+=" -q"              # Quiet Gradle output
  cmd+=" --console=plain" # Plain console output
  cmd+=" --stacktrace"    # Full stacktrace for errors
  cmd+=" -Pandroid.testInstrumentationRunnerArguments.filter=${filter}"

  echo "Running tests for ${module} (${variant})"
  # shellcheck disable=SC2086
  eval "${cmd}"
}

# Run a Gradle task with clean output
function grun() {
  local task="$1"
  shift

  # Build command with clean output
  local cmd="./gradlew"
  cmd+=" ${task}"
  cmd+=" -q"                     # Quiet Gradle output
  cmd+=" --console=plain"        # Plain console output
  [[ "$#" -gt 0 ]] && cmd+=" $*" # Add any additional arguments

  echo "Running Gradle task: ${task}"
  # shellcheck disable=SC2086
  eval "${cmd}"
}

# Clean Gradle caches and build files
function gclear() {
  echo "Cleaning Gradle caches and build files..."
  rm -rf ~/.gradle/caches/
  rm -rf .gradle
  rm -rf ./*build
  rm -rf build
  ./gradlew clean
  echo "Gradle clean complete"
}

# Show dependencies for a module
function gdeps() {
  local module="${1:-.}"
  echo "Showing dependencies for ${module}"
  ./gradlew "${module}:dependencies" --configuration implementation
}

# Build a module with specified variant
function gbuild() {
  local variant="${1:-Debug}"
  local module="${2:-.}"

  echo "Building ${module} (${variant})"
  ./gradlew "${module}:assemble${variant}" --console=plain
}

# Show all tasks for current project or specific module
function gtasks() {
  local module="${1:-.}"
  echo "Available Gradle tasks for ${module}:"
  ./gradlew "${module}:tasks" --all
}
