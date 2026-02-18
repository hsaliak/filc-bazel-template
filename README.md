# Fil-C Bazel Template

This repository is a template for bootstrapping new Bazel projects using the [Fil-C compiler](https://github.com/pizlonator/fil-c). Fil-C is a memory-safe C/C++ compiler that provides spatial and temporal safety.

## Getting Started

To create a new project using this template:

1.  **Create your repository**:
    ```bash
    gh repo create my-filc-project --template your-username/filc-bazel-toolchain --public
    cd my-filc-project
    ```
    *(Alternatively, clone this repository and remove the `.git` directory)*.

2.  **Verify the setup**:
    ```bash
    bazel build //src:hello
    ```

## Creating New Targets

Since this template is pre-configured with the Fil-C toolchain, you can use standard Bazel C++ rules. Any `cc_binary`, `cc_library`, or `cc_test` target will automatically be built using `filcc`.

### Example Binary

In a `BUILD.bazel` file:

```python
cc_binary(
    name = "my_app",
    srcs = ["my_app.c"],
)
```

### Example Library

```python
cc_library(
    name = "my_lib",
    srcs = ["my_lib.c"],
    hdrs = ["my_lib.h"],
)

cc_binary(
    name = "my_app",
    srcs = ["my_app.c"],
    deps = [":my_lib"],
)
```

No special attributes are required. The `.bazelrc` in this repo ensures that `--extra_toolchains=//toolchain:filc_toolchain` is passed, making Fil-C the preferred toolchain.

## Project Structure

- `toolchain/`: Contains the Bazel CC toolchain definition.
- `src/`: A sample C project to get you started.
- `MODULE.bazel`: Configures the Fil-C repository and registers the toolchain.
- `.bazelrc`: Sets default flags to use the Fil-C toolchain.

## How it Works

The toolchain uses a wrapper script (`toolchain/bin/filcc_wrapper.sh`) that dynamically locates the `filcc` binary within the Bazel sandbox. It handles path mapping and ensure all necessary include paths are passed to the compiler using relative paths, satisfying Bazel's hermeticity requirements.

## Verification

To verify that a binary has been compiled with Fil-C (and thus includes its safety checks), use the provided script:

```bash
./scripts/check_filc.sh bazel-bin/src/success
```

## Examples

- `src/fail.c`: Demonstrates a use-after-free bug that Fil-C detects and stops.
- `src/success.c`: A standard safe C program.

To run the success case:
```bash
bazel run //src:success
./scripts/check_filc.sh bazel-bin/src/success
```

To run the failure case (will trigger a Fil-C panic):
```bash
bazel run //src:fail
```

## Build Characteristics

Fil-C binaries are **statically linked** by default. This ensures that the custom runtime and safety checks are bundled with the executable. You can verify this using the `file` command:

```bash
file bazel-bin/src/success
```
