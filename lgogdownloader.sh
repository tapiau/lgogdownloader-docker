#!/bin/bash

REPO=https://github.com/Sude-/lgogdownloader.git
DOCKER_IMAGE="tapiau/lgogdownloader"
DOCKER_TAG=$(git ls-remote --tags ${REPO} \
           		| awk '{print $2}' \
           		| grep -E 'refs/tags/v[0-9]+\.[0-9]+(\.[0-9]+)?(-[0-9A-Za-z\.-]+)?(\+[0-9A-Za-z\.-]+)?$' \
           		| sort -V \
           		| tail -n1 \
           		| sed 's/refs\/tags\///' \
           	)
DATADIR="$(pwd)"
DEBUG=false

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --datadir=*)
      DATADIR="${arg#*=}"
      shift
      ;;
    --docker-tag=*)
      DOCKER_TAG="${arg#*=}"
      shift
      ;;
    --help)
      echo "Usage: $0 [--datadir=] [--docker-tag=] [--help]"
      echo "  --datadir=DIR   Directory to store downloaded files (default: current directory)"
      echo "  --docker-tag=TAG Docker image tag (default: latest taken from ${REPO})"
      exit 0
      ;;
  esac
done

if [[ "$(docker images -q ${DOCKER_IMAGE}:${DOCKER_TAG} 2> /dev/null)" == "" ]]; then
  if ! docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}; then
    DOCKERFILE=$(sed -n '/^##Dockerfile##/,$p' $0 | tail -n +2)
    echo "${DOCKERFILE}" | docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -f - .
  fi
fi

DOCKER_OPTIONS=()
DOCKER_OPTIONS+=("-it --rm")
DOCKER_OPTIONS+=("-u ${USER}")
DOCKER_OPTIONS+=("-v /${USER}/.config/lgogdownloader:/root/.config/lgogdownloader")
DOCKER_OPTIONS+=("-v /${USER}/.cache/lgogdownloader:/root/.cache/lgogdownloader")
DOCKER_OPTIONS+=("-v ${DATADIR}:/data")

DOCKER="docker run ${DOCKER_OPTIONS[@]} ${DOCKER_IMAGE}:${DOCKER_TAG}"

DEFAULT_OPTIONS="--no-color --verbosity=-1 --threads=16 --info-threads=32"

#lgogdownloader --download --threads=16 --info-threads=32
#./lgogdownloader --download --threads=16 --info-threads=32 --game crysis
# cyberpunk_2077_game cyberpunk_2077_goodies_collection

# --threads=16 --info-threads=32 --download --game the_witcher_3_wild_hunt_game_of_the_year_edition_game

if [ "${DEBUG}" = true ]; then
  echo "${DOCKER} lgogdownloader ${DEFAULT_OPTIONS} $*"
fi

#echo ${DOCKER} lgogdownloader ${DEFAULT_OPTIONS} $*
${DOCKER} lgogdownloader ${DEFAULT_OPTIONS} $*

exit 0

##Dockerfile##
FROM debian AS builder

RUN apt-get update
RUN apt-get install -y \
    git mc \
    build-essential libcurl4-openssl-dev libboost-regex-dev \
    libjsoncpp-dev librhash-dev libtinyxml2-dev libtidy-dev \
    libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
    libboost-date-time-dev libboost-iostreams-dev cmake \
    pkg-config zlib1g-dev qtwebengine5-dev ninja-build \
    libcrypto++-dev libssl-dev
#COPY . /app/
RUN git clone https://github.com/Sude-/lgogdownloader /app
WORKDIR /app

ARG TAG

RUN git pull && git checkout ${TAG}
RUN cmake -B build \
    -DCMAKE_INSTALL_PREFIX=/usr  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DUSE_QT_GUI=OFF \
    -GNinja
RUN ninja -Cbuild install

FROM debian AS runner
RUN apt-get update \
    && apt-get install -y  \
        libboost-filesystem1.74  \
        libboost-regex1.74  \
        libboost-program-options1.74  \
        libboost-iostreams1.74  \
        libcurl4 \
        libjsoncpp25 \
        libtinyxml2-9 \
        librhash0 \
        libtidy5deb1 \
    && apt-get clean
COPY --from=builder /app/build/lgogdownloader /usr/bin/lgogdownloader
COPY lgogdownloader.sh /root/
WORKDIR /data
#ENTRYPOINT ["/usr/bin/lgogdownloader"]

