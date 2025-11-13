set -ex

# --- Define Variables ---
FLOPPY_IMG="/app/floppy.img"

if [ ! -f "$FLOPPY_IMG" ]; then
    echo "Error: Floppy image $FLOPPY_IMG not found. Run ./build.sh first."
    exit 1
fi

# --- QEMU Run ---
QEMU_EXTRA=${QEMU_EXTRA:-""}

if [ -n "$DISPLAY" ]; then
  echo "Launching QEMU (graphical) with floppy image..."
  exec qemu-system-i386 -fda "$FLOPPY_IMG" -boot a -m 16 $QEMU_EXTRA
else
  echo "No DISPLAY detected — launching QEMU in text mode (-nographic)."
  # -nographic redirects serial output to the console.
  exec qemu-system-i386 \
    -drive file="$FLOPPY_IMG",format=raw,if=floppy \
    -boot a \
    -m 16 \
    -nographic \
    $QEMU_EXTRA
fi