#!/bin/bash
# check_filc.sh: Verify if a binary was compiled with the Fil-C compiler.

if [ -z "$1" ]; then
  echo "Usage: $0 <binary>"
  exit 1
fi

if ! command -v nm &> /dev/null; then
  echo "Error: nm is not installed."
  exit 1
fi

# We look for 'filc_' symbols which indicate the Fil-C runtime is present.
if nm "$1" 2>/dev/null | grep -q "filc_"; then
  echo "SUCCESS: $1 was compiled with Fil-C."
  exit 0
else
  echo "FAILURE: $1 was NOT compiled with Fil-C."
  exit 1
fi
