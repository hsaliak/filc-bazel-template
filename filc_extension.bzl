load("//:filc_repo.bzl", "filc_repo")

def _filc_ext_impl(module_ctx):
    filc_repo(
        name = "filc",
        urls = ["https://github.com/pizlonator/fil-c/archive/refs/heads/deluge.tar.gz"],
        strip_prefix = "fil-c-deluge",
        integrity = "sha256-LaEp3fC3lz9mB5f6pGtaJ8i9JufaxzGyGd5nFTgR7lM=",
        patch_cmds = [
            # Patching phase (one-off edits)
            "find . -name '*.sh' -exec sed -i 's/-DLLVM_ENABLE_LLD=ON/-DLLVM_ENABLE_LLD=OFF/g' {} +",
            "find . -name '*.sh' -exec sed -i 's/RelWithDebInfo/Release/g' {} +",
            "sed -i 's/export CMAKEOPTIONS=\"/export CMAKEOPTIONS=\"-DCMAKE_C_FLAGS=-pipe -DCMAKE_CXX_FLAGS=-pipe /' configure_llvm.sh",
        ],
        build_file_content = """
package(default_visibility = ["//visibility:public"])
filegroup(name = "compiler_binaries", srcs = glob(["build/bin/*"]))
filegroup(name = "pizfix", srcs = glob(["pizfix/**"]))
filegroup(name = "all_files", srcs = [":compiler_binaries", ":pizfix"])
""",
    )

filc_ext = module_extension(implementation = _filc_ext_impl)
