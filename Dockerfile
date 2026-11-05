# gbe_fork (Steam client emulator) built with the steamrt4 toolchain.
#   docker build --build-arg UPSTREAM_REF=release-2026_09_27 --output type=local,dest=out .
FROM registry.gitlab.steamos.cloud/steamrt/steamrt4/sdk AS build
ARG PREMAKE_TAG=v5.0.0-beta8

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests cmake p7zip-full \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "$PREMAKE_TAG" https://github.com/premake/premake-core.git /tmp/premake-src \
    && cd /tmp/premake-src \
    && ./Bootstrap.sh \
    && cp bin/release/premake5 bin/release/luasocket.so /usr/local/bin/ \
    && rm -rf /tmp/premake-src

ARG UPSTREAM_REF
RUN test -n "$UPSTREAM_REF" \
    && git clone --branch "$UPSTREAM_REF" --recurse-submodules -j8 https://github.com/Detanup01/gbe_fork.git /src/gbe

RUN cd /src/gbe \
    && export CMAKE_GENERATOR="Unix Makefiles" \
    && premake5 --file=premake5-deps.lua --deps-dir=/artifacts/deps --64-build --all-ext --all-build --j="$(nproc)" --os=linux gmake2 \
        --custom-cmake=/usr/bin/cmake --custom-extractor=/usr/bin/7za

RUN cd /src/gbe \
    && sed -i 's|    targetname "generate_interfaces_%{cfg.platform}"|&\n    filter {}\n    links "pthread"|' premake5.lua \
    && export CMAKE_GENERATOR="Unix Makefiles" \
    && premake5 --file=premake5.lua --build-dir=/artifacts --deps-dir=/artifacts/deps --genproto --os=linux gmake2 \
    && cd /src/gbe/build/project/gmake/linux \
    && make config=release_x64 api_regular steamclient_regular tool_generate_interfaces lib_steamnetworkingsockets -j"$(nproc)"

ARG REVISION=1
RUN R=/artifacts/linux/gmake/release \
    && mkdir -p /out \
    && cp "$R/regular/x64/libsteam_api.so" "$R/regular/x64/steamclient.so" /out/ \
    && cp "$R/tools/generate_interfaces/generate_interfaces_x64" /out/generate_interfaces \
    && cp "$R/steamnetworkingsockets/x64/libsteamnetworkingsockets.so" /out/ \
    && { echo "upstream=https://github.com/Detanup01/gbe_fork"; \
         echo "tag=$UPSTREAM_REF"; \
         echo "commit=$(git -C /src/gbe rev-parse HEAD)"; \
         echo "revision=$REVISION"; \
         echo "premake=$PREMAKE_TAG"; \
         echo "steamrt=$(. /etc/os-release && echo "$VERSION_CODENAME $BUILD_ID")"; \
       } > /out/BUILDINFO \
    && cat /out/BUILDINFO

FROM scratch
COPY --from=build /out/ /
