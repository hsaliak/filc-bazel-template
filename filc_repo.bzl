load("@bazel_tools//tools/build_defs/repo:utils.bzl", "patch", "workspace_and_buildfile")

def _filc_repo_impl(repository_ctx):
    repository_ctx.download_and_extract(
        url = repository_ctx.attr.urls,
        strip_prefix = repository_ctx.attr.strip_prefix,
        integrity = repository_ctx.attr.integrity,
    )

    # 1. Patch the scripts
    for cmd in repository_ctx.attr.patch_cmds:
        res = repository_ctx.execute(["bash", "-c", cmd], timeout = 600)
        if res.return_code != 0:
            fail("Error applying patch command %s: %s %s" % (cmd, res.stderr, res.stdout))

    # 2. Run the actual build
    build_script = """
set -e
echo "Starting Fil-C build process..."
mkdir -p build_tmp
export TMPDIR=$PWD/build_tmp
./build_base.sh
echo "Fil-C build process finished successfully!"
"""
    repository_ctx.file("run_build.sh", build_script, executable = True)
    
    # We set quiet = False to see the output in the console
    res = repository_ctx.execute(["./run_build.sh"], timeout = 7200, quiet = False)
    if res.return_code != 0:
        fail("Fil-C build failed with code %d: %s %s" % (res.return_code, res.stderr, res.stdout))

    workspace_and_buildfile(repository_ctx)

filc_repo = repository_rule(
    implementation = _filc_repo_impl,
    attrs = {
        "urls": attr.string_list(mandatory = True),
        "strip_prefix": attr.string(),
        "integrity": attr.string(),
        "patch_cmds": attr.string_list(),
        "build_file": attr.label(),
        "build_file_content": attr.string(),
        "workspace_file": attr.label(),
        "workspace_file_content": attr.string(),
    },
)
