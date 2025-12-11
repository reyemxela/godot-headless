# godot-headless

Heavily inspired by [jonstonchan/godot](https://hub.docker.com/r/jonstonchan/godot), but built for my own requirements and preferences.

This is a large image, as it currently includes all export templates.

## Usage:
```bash
[docker|podman] run --rm \
  -v .:/project \
  [-v <release-keystore-path>:/keys] \
  ghcr.io/reyemxela/godot-headless:latest \
    [--release-file <keystore base filename>] \
    [--release-user <keystore username>] \
    [--release-pass <keystore password>] \
  [godot options]
```

## Examples:
These examples assume the following:

| | |
|-|-|
| Export preset name    | `Android`                       |
| Release keystore file | `~/androidkeys/upload.keystore` |
| Release username      | `upload`                        |
| Release password      | `mypassword`                    |

### Debug build:
```bash
podman run --rm \
  -v .:/project \
  ghcr.io/reyemxela/godot-headless:4.5.1 \
  --export-debug Android
```

### Release build:
```bash
podman run --rm \
  -v .:/project \
  -v ~/androidkeys:/keys \
  ghcr.io/reyemxela/godot-headless:4.5.1 \
  --release-file "upload.keystore" \
  --release-user "upload" \
  --release-pass "mypassword" \
  --export-release Android
```

## Notes:
The `--release-<file|user|pass>` options don't currently override existing settings in the export preset. The problematic one is the path to the keystore file, since the path inside the container is different than outside.  
The easiest fix is to just remove the release settings (or at least the path) from the export preset and specify them in the run command as shown in the examples.