# Dockerfile — build & run 16-bit bootloader + game under QEMU
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Install required packages: nasm for assembling, build-essential for linking,
# qemu-system-x86 for boot/emulation, mtools & dosfstools useful for images.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         nasm build-essential qemu-system-x86 qemu-system-gui mtools dosfstools \
    && rm -rf /var/lib/apt/lists/*

# Copy source directory into image
COPY src/ /app/src/

# Add simple build+run helper script.
# The script:
#  - Assembles .asm files:
#      * if file contains "org 0x7c00" (case-insensitive) -> assembled as raw boot binary (-f bin)
#      * otherwise -> assembled as ELF64 (-f elf64) and linked into a Linux executable
#  - If a boot binary (boot*.bin or any .bin created from org 0x7c00) exists:
#      * creates 1.44MB floppy.img
#      * writes boot.bin into sector 0
#      * writes kernel.bin (if present) into sector 1
#  - Finally runs QEMU with the floppy image
RUN cat > /app/build_and_run.sh <<'SH' \
 && chmod +x /app/build_and_run.sh
#!/bin/sh
set -ex

cd /app/src || exit 1

# clean
rm -f /app/app /app/floppy.img /app/boot.bin /app/kernel.bin
rm -f *.o *.bin 2>/dev/null || true

# Assemble files
for f in *.asm; do
  [ -f "$f" ] || continue
  echo "==== Processing $f ===="
  if grep -qi "org *0x7c00" "$f"; then
    # likely a bootloader: produce flat binary
    out="${f%.asm}.bin"
    nasm -f bin "$f" -o "$out"
    echo "Produced boot-style binary: $out"
    # If user named it boot.asm, copy to boot.bin
    case "$f" in
      boot.asm|Boot.asm|BOOT.asm) cp -f "$out" /app/boot.bin ;;
    esac
  else
    # assemble + link as Linux x86_64 program
    obj="${f%.asm}.o"
    exe="${f%.asm}"
    nasm -f elf64 "$f" -o "$obj"
    ld "$obj" -o "/app/$exe" || true
    echo "Produced linux executable: /app/$exe"
  fi
done

# If we produced any .bin that isn't boot.bin, and boot.bin exists, copy it as kernel.bin
# (this is a convenience: many setups produce kernel.bin or stage2.bin)
if [ -z /app/boot.bin ] 2>/dev/null; then :; fi
# Prefer explicitly created kernel.bin in src; else pick any non-boot .bin
if [ -f /app/boot.bin ]; then
  echo "boot.bin already created in /app"
fi

# pick boot binary if missing
if [ ! -f /app/boot.bin ]; then
  # try find any .bin with org 0x7c00 (we already made them in src)
  for b in *.bin; do
    # skip empty
    [ -s "$b" ] || continue
    # prefer files that contain the 0x55AA signature at end (512 bytes)
    # if the file is exactly 512 bytes or contains the signature, assume it's a boot sector
    size=$(stat -c%s "$b")
    if [ "$size" -le 512 ]; then
      cp -f "$b" /app/boot.bin && break
    else
      # check last 2 bytes
      if [ "$(tail -c 2 "$b" | xxd -p)" = "55aa" ]; then
        cp -f "$b" /app/boot.bin && break
      fi
    fi
  done
fi

# If we have any other .bin that isn't boot.bin, call it kernel.bin (sector 1)
if [ -f /app/boot.bin ]; then
  for b in *.bin; do
    [ -f "$b" ] || continue
    [ "/app/$b" = "/app/boot.bin" ] && continue
    cp -f "$b" /app/kernel.bin && break
  done
fi

# If there is a boot.bin, create a 1.44MB floppy and write boot + kernel
if [ -f /app/boot.bin ]; then
  echo "Creating 1.44MB floppy image /app/floppy.img"
  dd if=/dev/zero of=/app/floppy.img bs=512 count=2880 status=none
  # Write boot sector (sector 0) — notrunc so we don't overwrite whole file
  dd if=/app/boot.bin of=/app/floppy.img bs=512 count=1 conv=notrunc status=none
  # If kernel.bin exists, write it starting at sector 1
  if [ -f /app/kernel.bin ]; then
    echo "Writing kernel.bin to sector 1"
    dd if=/app/kernel.bin of=/app/floppy.img bs=512 seek=1 conv=notrunc status=none
  fi
  echo "Floppy image ready: /app/floppy.img"
else
  echo "No boot binary detected. Skipping floppy image creation."
fi

# QEMU run options:
# - If DISPLAY is available and X is forwarded into the container, QEMU will open an SDL/GTK window.
# - If DISPLAY is not present, we fall back to -nographic (text-only).
# You can override QEMU_EXTRA env var at runtime to add e.g. '-vga std' or other options.
QEMU_EXTRA=${QEMU_EXTRA:-""}

if [ -f /app/floppy.img ]; then
  # Use i386 qemu for real-mode bootloaders
  if [ -n "$DISPLAY" ]; then
    echo "Launching QEMU (graphical) with floppy image..."
    exec qemu-system-i386 -fda /app/floppy.img -boot a -m 16 $QEMU_EXTRA
  else
    echo "No DISPLAY detected — launching QEMU in text mode (-nographic)."
    # -nographic will route serial to console; if your bootloader uses VGA graphics it won't show.
    exec qemu-system-i386 \
      -drive file=/app/floppy.img,format=raw,if=floppy \
      -boot a \
      -m 16 \
      -nographic \
      $QEMU_EXTRA > /app/qemu.log 2>&1
  fi
else
  echo "No floppy image. If you built plain linux programs, /app/<name> executables are available."
  echo "Listing /app:"
  ls -la /app || true
  # fallback: drop to sh to let user inspect artifacts
  exec /bin/sh
fi
SH

RUN sed -i 's/\r$//' /app/build_and_run.sh
# Make sure build script is executable and entrypoint runs it
ENTRYPOINT ["/app/build_and_run.sh"]
