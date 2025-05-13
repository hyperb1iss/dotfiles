# Java version switching aliases
# Assumes JDKs are installed in /usr/lib/jvm/
# Add to your .bashrc or .zshrc

# Skip entire module if not in full installation
is_minimal && return 0

# Function to switch Java version
function setjdk() {
	if [[ $# -ne 1 ]]; then
		echo "Usage: setjdk <version>"
		echo "Available versions:"
		find /usr/lib/jvm -maxdepth 1 -name "java-*-openjdk-amd64" -o -name "java-*-oracle" |
			sed 's/.*\///' | sort -V
		return 1
	fi

	local version=$1
	local java_home="/usr/lib/jvm/java-${version}-openjdk-amd64"

	if [[ ! -d "${java_home}" ]]; then
		echo "Error: Java ${version} is not installed at ${java_home}"
		return 1
	fi

	# Set JAVA_HOME
	export JAVA_HOME="${java_home}"

	# Clean up PATH and add new Java path
	local new_path
	new_path=$(echo "${PATH}" | sed "s|/usr/lib/jvm/[^/]*/bin:||g")
	export PATH="${JAVA_HOME}/bin:${new_path}"

	echo "Switched to Java ${version}"
	java -version
}

# Function to create dynamic aliases for available Java versions
function setup_java_aliases() {
	# Find all installed Java versions
	# shellcheck disable=SC2162
	find /usr/lib/jvm -maxdepth 1 \( -name "java-*-openjdk-amd64" -o -name "java-*-oracle" \) |
		sort -V | while read java_path; do
		line=$(basename "${java_path}")
		version=$(echo "${line}" | sed -E 's/java-([0-9]+).*/\1/')

		# Only create aliases for Java 8 and newer
		if [[ "${version}" -ge 8 ]]; then
			# Use eval to create the alias at runtime, avoiding SC2139
			# shellcheck disable=SC2139,SC2140,SC1090
			eval "alias java${version}='setjdk ${version}'"
		fi
	done
}

# Function to list available versions with commands
function list_java_versions() {
	echo "╔════════════════════════════════════════════════╗"
	echo "║           Available Java Versions              ║"
	echo "╚════════════════════════════════════════════════╝"

	local current_version
	current_version=$(java -version 2>&1 | grep version | cut -d'"' -f2 | cut -d'.' -f1) || current_version=""

	# shellcheck disable=SC2162
	find /usr/lib/jvm -maxdepth 1 \( -name "java-*-openjdk-amd64" -o -name "java-*-oracle" \) |
		sort -V | while read java_path; do
		line=$(basename "${java_path}")
		version=$(echo "${line}" | sed -E 's/java-([0-9]+).*/\1/')

		# Skip versions less than 8 as they're likely invalid or too old
		if [[ "${version}" -lt 8 ]]; then
			continue
		fi

		if [[ "${version}" = "${current_version}" ]]; then
			echo "* Java ${version} (current)"
		else
			echo "  Java ${version}"
		fi
		echo "    Commands: java${version}, setjdk ${version}"
		echo
	done

	echo "Usage:"
	echo "  - Use 'java<version>' (e.g., java11) for quick switching"
	echo "  - Use 'setjdk <version>' (e.g., setjdk 11) for explicit switching"
}

# Replace the javalist alias with the new function
alias javalist="list_java_versions"

# Setup the Java aliases when the script is sourced
setup_java_aliases
