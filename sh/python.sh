# python.sh
# Helper functions for Python and Django development

# Create and activate Python virtual environment
function venv() {
	if [[ -z "$1" ]]; then
		DIR="venv"
	else
		DIR="$1"
	fi
	python -m venv "${DIR}"
	# shellcheck disable=SC1090
	source "${DIR}/bin/activate"
}

# Activate virtual environment, searching up directory tree
function va() {
	local dir="${PWD}"
	while [[ "${dir}" != "/" ]]; do
		for venv in "${dir}"/{venv,.venv,env,.env}; do
			if [[ -f "${venv}/bin/activate" ]]; then
				# shellcheck disable=SC1090
				source "${venv}/bin/activate"
				echo "Activated virtualenv: ${venv}"
				return 0
			fi
		done
		dir="$(dirname "${dir}")"
	done
	echo "No virtualenv found"
	return 1
}

# Deactivate virtual environment
function vd() {
	deactivate 2>/dev/null || echo "No virtualenv is active"
}

# Run Django development server on specified port (default 8000)
function drs() {
	local port=${1:-8000}
	python manage.py runserver "0.0.0.0:${port}"
}

# Django shell plus (if installed) or regular shell
function dsh() {
	if python manage.py help shell_plus >/dev/null 2>&1; then
		python manage.py shell_plus
	else
		python manage.py shell
	fi
}

# Run Django migrations
function dmm() {
	python manage.py makemigrations "$@"
}

# Apply Django migrations
function dm() {
	python manage.py migrate "$@"
}

# Create Django superuser
function dsu() {
	python manage.py createsuperuser
}

# Django test with optional path
function dt() {
	if [[ -z "$1" ]]; then
		python manage.py test
	else
		python manage.py test "$@"
	fi
}

# Run pytest with common options
function pt() {
	pytest -v --tb=short "$@"
}

# Run pytest with debug logging
function ptd() {
	pytest -v --log-cli-level=DEBUG --tb=short "$@"
}

# Run black formatter on directory or file
function black() {
	if [[ -z "$1" ]]; then
		command black .
	else
		command black "$@"
	fi
}

# Run isort on directory or file
function isort() {
	if [[ -z "$1" ]]; then
		command isort .
	else
		command isort "$@"
	fi
}

# Run flake8 on directory or file
function flake() {
	if [[ -z "$1" ]]; then
		flake8 .
	else
		flake8 "$@"
	fi
}

# Format code with black and isort
function format() {
	if [[ -z "$1" ]]; then
		black .
		isort .
	else
		black "$@"
		isort "$@"
	fi
}
