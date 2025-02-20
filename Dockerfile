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
