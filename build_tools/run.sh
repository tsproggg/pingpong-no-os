set -ex

# --- Define Variables ---
FLOPPY_IMG="/app/floppy.img"

if [ ! -f "$FLOPPY_IMG" ]; then
    echo "Error: Floppy image $FLOPPY_IMG not found. Run ./build.sh first."
    exit 1
fi

# --- QEMU Run ---
QEMU_EXTRA=${QEMU_EXTRA:-""}

echo "Launching QEMU (graphical) with floppy image..."
  # -nographic redirects serial output to the console.
exec qemu-system-i386 \
    -drive file="$FLOPPY_IMG",format=raw,if=floppy \
    -boot a \
    -m 16 \
    -vga std \
    -vnc :0 \
    $QEMU_EXTRA