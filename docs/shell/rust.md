# Rust

_Cargo workflows, simplified_

Rust development is elegant. These shortcuts make it even better.

## Environment

Rust environment initializes automatically via `sh/rust.sh`:

```bash
# Auto-added to PATH:
~/.cargo/bin              # Cargo binaries
~/.rustup/toolchains/*/bin  # Toolchain binaries
```

No manual PATH configuration needed.

## Cargo Aliases

| Alias    | Command        | Description       |
| -------- | -------------- | ----------------- |
| `cr`     | `cargo run`    | Run the project   |
| `cb`     | `cargo build`  | Build the project |
| `ct`     | `cargo test`   | Run tests         |
| `cf`     | `cargo fmt`    | Format code       |
| `cc`     | `cargo clippy` | Lint code         |
| `cbench` | `cargo bench`  | Run benchmarks    |

Note: `cc` clashes with the C compiler on some systems, but Rust context makes it obvious.

## Functions

### `cadd` — Add Dependencies

Add crates to your `Cargo.toml`:

```bash
cadd serde           # Add serde
cadd serde serde_json  # Add multiple
cadd tokio --features full  # With features
```

Requires `cargo-edit`:

```bash
cargo install cargo-edit
```

Way better than manually editing `Cargo.toml`.

### `cwatch` — Auto-Rebuild

Watch files and rebuild on changes:

```bash
cwatch              # Watch and rebuild
cwatch test         # Watch and run tests
cwatch run          # Watch and run
cwatch 'check --all-targets'  # Custom command
```

Requires `cargo-watch`:

```bash
cargo install cargo-watch
```

Essential for development. Instant feedback on every save.

### `rswitch` — Toolchain Switcher

Switch between Rust toolchains interactively:

```bash
rswitch
# fzf list of installed toolchains
# Select one to activate
```

Useful when testing compatibility across stable/beta/nightly.

### `crtree` — Dependency Tree

Interactive dependency tree viewer:

```bash
crtree
# Shows dependency tree with fzf
# Navigate your deps interactively
```

Great for understanding your dependency graph.

## Toolchain Management

Managed by `rustup`:

```bash
# Update all toolchains
rustup update

# Set default toolchain
rustup default stable
rustup default nightly

# Add compilation targets
rustup target add wasm32-unknown-unknown
rustup target add x86_64-pc-windows-gnu

# List installed toolchains
rustup toolchain list
```

## Workflows

### New Project

```bash
# Create binary project
cargo new myproject
cd myproject

# Or create library
cargo new --lib mylib
cd mylib

# Run it
cr
```

### Development Loop

```bash
# Start watch mode
cwatch

# In another terminal:
# Edit code
vim src/main.rs

# Tests run automatically on save
# Or run manually:
ct

# Check with clippy
cc
```

Instant feedback. Make a change, see the result immediately.

### Before Commit

```bash
# Format
cf

# Lint
cc

# Test
ct

# If all pass, commit
gig
```

Rust's tooling makes this workflow fast.

### Adding Dependencies

```bash
# Add a crate
cadd reqwest

# With features
cadd tokio --features full,macros

# Dev dependency
cadd --dev proptest
```

Much faster than manually editing `Cargo.toml`.

### Release Build

```bash
# Build optimized binary
cargo build --release

# Binary is in target/release/
ls -lh target/release/myproject
```

Release builds are significantly faster than debug builds.

### Cross-Compilation

```bash
# Add target
rustup target add x86_64-pc-windows-gnu

# Build for target
cargo build --target x86_64-pc-windows-gnu --release
```

### Benchmarking

```bash
# Run benchmarks
cbench

# Specific benchmark
cbench my_bench_function
```

Requires nightly toolchain for some benchmark features.

## Common cargo Commands

```bash
# Check without building (fast)
cargo check

# Build docs
cargo doc --open

# Clean build artifacts
cargo clean

# Update dependencies
cargo update

# Show outdated deps
cargo outdated  # Requires cargo-outdated

# Audit for security issues
cargo audit  # Requires cargo-audit
```

## Pro Tips

**Use `cargo check` during development**: It's way faster than `cargo build` and catches most errors.

**Install cargo-edit and cargo-watch**: They're essential. `cargo install cargo-edit cargo-watch`

**Clippy is your friend**: It catches bugs and suggests idioms. Run `cc` before every commit.

**Format automatically**: Configure your editor to run `rustfmt` on save. Consistency matters.

**Watch mode always**: Keep `cwatch` running in a tmux pane. Instant feedback beats manual rebuilds.

**Use release builds for testing performance**: Debug builds are slow. Always benchmark with `--release`.

**Learn the Cargo.toml**: Understanding features, workspaces, and profiles will level up your Rust.

**Audit dependencies**: Run `cargo install cargo-audit` then `cargo audit` regularly. Security matters.

**Workspace for multi-crate projects**: Large projects benefit from Cargo workspaces. One `target/` dir, shared
dependencies.
