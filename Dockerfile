# Dockerfile focused on 16-bit Bootloader + Kernel Development
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TOOLS_DIR=/app/build_tools
WORKDIR /app

# Install nasm (assembler), build-essential (for ld) and qemu-system-i386 (emulator for 16-bit)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         nasm build-essential qemu-system-i386 \
    && rm -rf /var/lib/apt/lists/*

COPY src/ /app/src/
COPY build_tools/ ${BUILD_TOOLS_DIR}

RUN chmod +x ${BUILD_TOOLS_DIR}/build.sh
RUN chmod +x ${BUILD_TOOLS_DIR}/run.sh

# --- Update ENTRYPOINT to run both sequentially ---
# Run build, and if successful, run the emulator.
RUN sed -i 's/\r$//' ${BUILD_TOOLS_DIR}/build.sh ${BUILD_TOOLS_DIR}/run.sh
ENTRYPOINT ["/bin/bash", "-c", "${BUILD_TOOLS_DIR}/build.sh && ${BUILD_TOOLS_DIR}/run.sh"]