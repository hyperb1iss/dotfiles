# Python

_Virtual environments & Django shortcuts_

Python development is better with proper environment isolation. These tools make it painless.

## Virtual Environments

### `venv` — Create & Activate

Create and activate a virtual environment in one command:

```bash
venv              # Creates ./venv and activates it
venv myenv        # Creates ./myenv and activates it
```

No more separate `python -m venv` and `source activate` steps.

### `va` — Auto-Activate

Smart virtualenv activation that searches up the directory tree:

```bash
va
# Searches for: venv/, .venv/, env/, .env/
# Activates the first one found
# Checks parent directories too
```

Perfect for jumping into projects. No need to remember where the venv is.

### `vd` — Deactivate

Exit the current virtualenv:

```bash
vd
# Simple alias for deactivate
```

## Django Utilities

Quick shortcuts for Django development. All require being in a Django project.

### Development Server

```bash
drs         # python manage.py runserver (port 8000)
drs 3000    # python manage.py runserver 3000
```

### Shell

```bash
dsh
# Uses shell_plus if django-extensions is installed
# Falls back to regular Django shell
```

`shell_plus` auto-imports all models. Install it: `pip install django-extensions`

### Migrations

```bash
dmm         # python manage.py makemigrations
dm          # python manage.py migrate
```

The two most-used Django commands, now 3 keystrokes each.

### Admin

```bash
dsu         # python manage.py createsuperuser
```

Create admin users quickly.

### Tests

```bash
dt              # Run all tests
dt myapp        # Run specific app's tests
dt myapp.tests.test_views  # Specific test module
```

## Code Quality

### Formatting

```bash
black .           # Format all Python files with Black
isort .           # Sort imports
```

Or use a combined workflow (see below).

### Linting

```bash
flake .           # Run flake8 on current directory
```

Catches style issues and potential bugs.

## Testing

### pytest

```bash
pt              # Run pytest (verbose, short traceback)
ptd             # Run with debug logging enabled
```

pytest is better than unittest. Fight me.

## Workflows

### New Django Project

```bash
# Create project directory
mkdir myproject && cd myproject

# Create and activate venv
venv

# Install Django
pip install django

# Start project
django-admin startproject config .

# Run dev server
drs
```

### Existing Project

```bash
# Enter project
cd ~/projects/django-app

# Auto-activate venv
va

# Install dependencies
pip install -r requirements.txt

# Run migrations (if needed)
dm

# Start server
drs
```

### Before Commit

```bash
# Format code
black .
isort .

# Lint
flake .

# Run tests
pt

# If all green, commit
gig
```

### Django Development Loop

```bash
# Make model changes
vim myapp/models.py

# Create migrations
dmm

# Apply migrations
dm

# Test in shell
dsh
# >>> from myapp.models import MyModel
# >>> MyModel.objects.all()

# Run tests
dt myapp

# Start server
drs
```

### Managing Dependencies

```bash
# Activate venv
va

# Install new package
pip install requests

# Freeze dependencies
pip freeze > requirements.txt

# Or use pip-tools for better management:
pip install pip-tools
pip-compile requirements.in
pip-sync requirements.txt
```

## Pro Tips

**Always use virtualenvs**: Never install packages globally (except pip, virtualenv itself). `venv` makes it trivial.

**Use .env for secrets**: Store database passwords, API keys in `.env` files. Load with `python-dotenv`.

**Format before committing**: Black is opinionated. Just accept it and run `black .` before every commit.

**django-extensions is essential**: Get `shell_plus`, `runserver_plus`, and other useful management commands.
`pip install django-extensions`

**pytest > unittest**: More concise, better fixtures, better plugins. Install with `pip install pytest pytest-django`.

**Use requirements.in**: Keep high-level deps in `requirements.in`, generate `requirements.txt` with `pip-compile`. Lock
exact versions.

**Virtual environment in project**: Use `venv` or `.venv` as the directory name. Editors auto-detect these.

**Activate on cd**: Consider adding auto-activation to your shell config (check if in git repo, look for venv,
activate). The `va` command is a manual version of this.
