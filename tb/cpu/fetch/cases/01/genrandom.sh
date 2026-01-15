
# Get path to the current script.
SCRIPT_PATH="${BASH_SOURCE:-$0}"
FULL_PATH=$(realpath "$SCRIPT_PATH")
SCRIPT_DIR=$(dirname "$FULL_PATH")

# Dump a block of /dev/urandom into the imem file.
head -c 1K /dev/urandom >"$SCRIPT_DIR/imem"
cat "$SCRIPT_DIR/imem" >"$SCRIPT_DIR/res"
