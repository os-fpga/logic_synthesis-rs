SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
export ABC=${ROOT_DIR}/build/bin/abc
export DE=${ROOT_DIR}/build/bin/de
export LSORACLE=${ROOT_DIR}/build/bin/lsoracle
