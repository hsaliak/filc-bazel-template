# Fil-C Bazel Toolchain

This project provides a Bazel integration for the [Fil-C compiler](https://github.com/pizlonator/fil-c). Fil-C is a memory-safe C/C++ compiler that provides spatial and temporal safety by using a custom runtime and pointer representation.

## Features

- **Hermetic Toolchain**: Wraps the Fil-C compiler (`filcc`) to work seamlessly within the Bazel sandbox.
- **Automatic Setup**: Uses Bazel's repository rules to download and compile Fil-C from source.
- **Bzlmod Support**: Compatible with Bazel's modern module system.

## Prerequisites

- [Bazel](https://bazel.build/) (v6.0 or later recommended).
- A host C/C++ compiler (GCC or Clang) and standard build tools (make, cmake, etc.) required to build Fil-C.

## Usage

### Building a Target

To build a C target using the Fil-C toolchain, use the `--extra_toolchains` flag:

```bash
bazel build //src:hello
```

### Running the Binary

Once built, you can run the binary as usual. Fil-C binaries are typically linked statically with the Fil-C runtime.

```bash
./bazel-bin/src/hello
```

### Adding Fil-C to Your Project

1.  **Define the Fil-C Repository**: Add the following to your `MODULE.bazel`:

    ```python
    filc_repo = use_repo_rule("//:filc_repo.bzl", "filc_repo")

    filc_repo(
        name = "filc",
        urls = ["https://github.com/pizlonator/fil-c/archive/refs/heads/deluge.tar.gz"],
        strip_prefix = "fil-c-deluge",
        patch_cmds = [
            # Add any necessary patches here
        ],
    )
    ```

2.  **Configure the Toolchain**: Ensure the `toolchain/` directory is present in your project, and register it in your `MODULE.bazel`:

    ```python
    register_toolchains("//toolchain:filc_toolchain")
    ```

3.  **Build with Fil-C**: Use the flag or configure your `.bazelrc` to use the toolchain by default.

## Project Structure

- `toolchain/`: Contains the Bazel CC toolchain definition.
  - `bin/filcc_wrapper.sh`: The core wrapper that handles `filcc` invocation and path mapping in the sandbox.
  - `BUILD.bazel`: Toolchain and toolchain type definitions.
  - `cc_config.bzl`: Low-level toolchain configuration.
- `src/`: A sample C project.
- `filc_repo.bzl`: Repository rule for downloading and building Fil-C.

## How it Works

The `filcc_wrapper.sh` script dynamically locates the `filcc` binary and its associated `pizfix` resource directory within the Bazel sandbox. It handles the repository name mangling introduced by Bzlmod (e.g., mapping `external/filc` to `external/+filc_ext+filc`) and ensures all necessary include paths are passed to the compiler using relative paths, satisfying Bazel's hermeticity requirements.


## Default Toolchain

A `.bazelrc` file has been provided to make Fil-C the default toolchain for this workspace. You can now build simply with:

```bash
bazel build //src:hello
```
