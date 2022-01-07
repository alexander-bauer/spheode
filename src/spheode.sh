#!/bin/sh -eu

INSTALL_ROOT=$(realpath $(dirname $(realpath $0))/..)

REPO=/repo # we export this for dependent scripts
EXPORT=/export

AUTOBUILD_CMD=autobuild
EXPORT_CMD=export

DOCS=docs
DETECT=
PORT=8000
CHOWN=
BASECONF="$INSTALL_ROOT/share/spheode/conf"

usage() {
   echo "usage:" 1>&2
   echo "  $0 [options] <mode>" 1>&2
   echo "" 1>&2
   echo "modes:" 1>&2
   echo "  $AUTOBUILD_CMD       build and serve documentation, automatically refreshing on changes" 1>&2
   echo "  $EXPORT_CMD          build documentation once and save as an artifact" 1>&2
   echo "" 1>&2
   echo "options:" 1>&2
   echo "  --docs <dir>           docs directory relative to the repo root (default '${DOCS}')" 1>&2
   echo "  --detect               force VCS version detection even in --watch mode" 1>&2
   echo "  --port <port>          port to bind for --serve, default ${PORT}" 1>&2
   echo "  --chown <UID:GID>      ownership to set for export" 1>&2
   echo "  --baseconf <baseconf>  base internal spheode configuration directory (default '${BASECONF}')" 1>&2
}

# Normalize the arguments with getopt.
ARGS=$(getopt -n spheode --long docs:,detect,port:,chown:,baseconf: -- "$0" "$@")
if [[ $? != 0 ]]; then usage; exit 1; fi

# Replace the args with the normalized version.
eval set -- "$ARGS"

while true; do
    case "${1:-}" in
       --docs ) DOCS="$2"; shift 2 ;;
       --detect ) DETECT=true; shift ;;
       --port ) PORT="$2"; shift 2 ;;
       --chown ) CHOWN="$2"; shift 2 ;;
       --baseconf ) BASECONF="$2"; shift 2 ;;
       -- ) shift; break ;;
       *) break ;;
    esac
done

# Get the mode and check it.
if [[ $# == 0 ]]; then usage; exit 1; fi
MODE="$1"; shift
if [[ "$MODE" != "$AUTOBUILD_CMD" && "$MODE" != "$EXPORT_CMD" ]]; then usage; exit 1; fi

# If there are any remaining arguments, exit.
if [[ $# -gt 0 ]]; then usage; exit 1; fi

# Create a tempdir to work in.
TMPDIR=$(mktemp -t spheode.XXXXXX -d)

CONF=${TMPDIR}/conf
BUILD=${TMPDIR}/build

for d in "${CONF}" "${BUILD}"; do mkdir -p "$d"; done

# Find the real paths of various folders.
ABS_DOCS=$(realpath "${REPO}/${DOCS}")
ABS_EXPORT=$(realpath "${EXPORT}")

# Copy Spheode base configuration into the final conf directory.
rsync -a "${BASECONF}/" "${CONF}"

# For each of these files, add a link to the configuration directory if they exist.
if [[ -f "${ABS_DOCS}/conf.py" ]]; then
   ln -sf "${ABS_DOCS}/conf.py" "${CONF}/userconf.py"
fi
for f in prolog.rst epilog.rst; do
   if [[ -f "${ABS_DOCS}/${f}" ]]; then
      ln -sf "${ABS_DOCS}/${f}" "${CONF}/${f}"
   fi
done

CHOWN_FLAG=
if [[ ! -z "$CHOWN" ]]; then
  CHOWN_FLAG="--chown $CHOWN"
fi

# Export environment variables for use by the Sphinx config files.
export DOCS EXPORT REPO
case "$MODE" in
   "$AUTOBUILD_CMD" )
      (
         set -xe
         sphinx-autobuild -c "${CONF}" --host 0.0.0.0 --port "$PORT" "${ABS_DOCS}" "${BUILD}"
      )
      ;;
   "$EXPORT_CMD" )
      (
         set -xe
         sphinx-build -c "${CONF}" -b html "${ABS_DOCS}" "${BUILD}"
         rsync $CHOWN_FLAG --archive --delete "${BUILD}/" "${EXPORT}"
      )
      ;;
   * )
      usage
      exit 1
      ;;
esac
