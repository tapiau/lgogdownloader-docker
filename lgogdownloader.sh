#!/bin/bash

DOCKER_IMAGE="tapiau/lgogdownloader:v3.16"

DATADIR=""

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --datadir=*)
      DATADIR="${arg#*=}"
      shift
      ;;
  esac
done

if [ "${DATADIR}" == "" ]; then
  DATADIR="$(pwd)"
fi

DOCKER_OPTIONS=""
DOCKER_OPTIONS="${DOCKER_OPTIONS} -it --rm"
DOCKER_OPTIONS="${DOCKER_OPTIONS} -u ${USER}"
DOCKER_OPTIONS="${DOCKER_OPTIONS} -v /${USER}/.config/lgogdownloader:/root/.config/lgogdownloader"
DOCKER_OPTIONS="${DOCKER_OPTIONS} -v /${USER}/.cache/lgogdownloader:/root/.cache/lgogdownloader"
DOCKER_OPTIONS="${DOCKER_OPTIONS} -v ${DATADIR}:/data"

DOCKER="docker run ${DOCKER_OPTIONS} ${DOCKER_IMAGE}"

DEFAULT_OPTIONS="--no-color --verbosity=-1 --threads=16 --info-threads=32"

#lgogdownloader --download --threads=16 --info-threads=32
#./lgogdownloader --download --threads=16 --info-threads=32 --game crysis
# cyberpunk_2077_game cyberpunk_2077_goodies_collection

# --threads=16 --info-threads=32 --download --game the_witcher_3_wild_hunt_game_of_the_year_edition_game

${DOCKER} lgogdownloader ${DEFAULT_OPTIONS} $*
