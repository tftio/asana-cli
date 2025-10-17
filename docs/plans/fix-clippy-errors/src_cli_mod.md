# Fix Plan: src/cli/mod.rs

**Total Errors**: 3

## Error Summary by Category

| Category | Count | Lines Affected |
|----------|-------|----------------|
| Single match to if-let | 1 | 237-255 |
| Format string optimization | 2 | 245, 252 |

## Detailed Errors

### 1. Single Match to If-Let (Lines 237-255)

**Issue**: Using `match` with only one meaningful pattern when `if let` would be clearer.

**Current**:
```rust
match dir {
    Some(path) => {
        fs::create_dir_all(&path).with_context(|| {
            format!("failed to create manpage directory {}", path.display())
        })?;
        let output = path.join("asana-cli.1");
        let mut file = File::create(&output)
            .with_context(|| format!("failed to create manpage file {}", output.display()))?;
        write!(file, "{}", MANPAGE_SOURCE)
            .map_err(|err| anyhow!("failed to write manpage: {err}"))?;
        println!("Man page written to {}", output.display());
    }
    None => {
        let stdout = io::stdout();
        let mut handle = stdout.lock();
        write!(handle, "{}", MANPAGE_SOURCE)
            .map_err(|err| anyhow!("failed to write manpage: {err}"))?;
    }
}
```

**Fix**:
```rust
if let Some(path) = dir {
    fs::create_dir_all(&path).with_context(|| {
        format!("failed to create manpage directory {}", path.display())
    })?;
    let output = path.join("asana-cli.1");
    let mut file = File::create(&output)
        .with_context(|| format!("failed to create manpage file {}", output.display()))?;
    write!(file, "{MANPAGE_SOURCE}")
        .map_err(|err| anyhow!("failed to write manpage: {err}"))?;
    println!("Man page written to {}", output.display());
} else {
    let stdout = io::stdout();
    let mut handle = stdout.lock();
    write!(handle, "{MANPAGE_SOURCE}")
        .map_err(|err| anyhow!("failed to write manpage: {err}"))?;
}
```

**Difficulty**: Easy - straightforward refactor

---

### 2. Format String Optimization (Lines 245, 252)

**Issue**: Variables can be inlined directly into format strings instead of using positional arguments.

**Line 245**:
```rust
// Current
write!(file, "{}", MANPAGE_SOURCE)

// Fix
write!(file, "{MANPAGE_SOURCE}")
```

**Line 252**:
```rust
// Current
write!(handle, "{}", MANPAGE_SOURCE)

// Fix
write!(handle, "{MANPAGE_SOURCE}")
```

**Explanation**: Modern Rust supports inline variable interpolation in format strings, which is more readable and idiomatic.

**Difficulty**: Easy - inline variables into format strings

---

## Fix Order Recommendation

All three fixes can be done together as they're in the same function:

1. Convert match to if-let (line 237)
2. Inline format string in file write (line 245)
3. Inline format string in stdout write (line 252)

## Combined Fix

Here's the complete fixed `write_manpage` function:

```rust
fn write_manpage(dir: Option<PathBuf>) -> Result<()> {
    if let Some(path) = dir {
        fs::create_dir_all(&path).with_context(|| {
            format!("failed to create manpage directory {}", path.display())
        })?;
        let output = path.join("asana-cli.1");
        let mut file = File::create(&output)
            .with_context(|| format!("failed to create manpage file {}", output.display()))?;
        write!(file, "{MANPAGE_SOURCE}")
            .map_err(|err| anyhow!("failed to write manpage: {err}"))?;
        println!("Man page written to {}", output.display());
    } else {
        let stdout = io::stdout();
        let mut handle = stdout.lock();
        write!(handle, "{MANPAGE_SOURCE}")
            .map_err(|err| anyhow!("failed to write manpage: {err}"))?;
    }

    Ok(())
}
```

## Testing Notes

- Test manpage generation to file: `asana-cli manpage --dir /tmp/test`
- Test manpage generation to stdout: `asana-cli manpage`
- Verify manpage content is identical before and after fix
