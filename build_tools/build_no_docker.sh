set -ex

cd ./src || exit 2

# --- Define Variables ---
BOOT_ASM="boot.asm"
KERNEL_ASM="kernel.asm"
BOOT_BIN="../app/boot.bin"
KERNEL_BIN="../app/kernel.bin"
FLOPPY_IMG="../app/floppy.img"

mkdir -p ../app

# Clean artifacts
rm -f "$FLOPPY_IMG" "$BOOT_BIN" "$KERNEL_BIN"
rm -f *.o *.bin 2>/dev/null || true

# --- Check whether bootloader and kernel source files are present ---
if [ ! -f "$BOOT_ASM" ]; then
    echo "Error: Required file 'boot.asm' not found in src/."
    exit 3
fi

if [ ! -f "$KERNEL_ASM" ]; then
    echo "Error: Required file 'kernel.asm' not found in src/."
    exit 4
fi

# --- Assembling ---
echo "==== Assembling ===="
nasm -f bin "$BOOT_ASM" -o "$BOOT_BIN"
echo "Produced boot sector: $BOOT_BIN"

nasm -f bin "$KERNEL_ASM" -o "$KERNEL_BIN"
echo "Produced kernel binary: $KERNEL_BIN"

echo
echo "Kernel size (bytes): "
wc -c "$KERNEL_BIN" | awk '{print $1}'
echo

# --- Floppy Image Creation ---
echo "Creating 1.44MB floppy image $FLOPPY_IMG"
# Create a zeroed 1.44MB image (2880 sectors of 512 bytes)
dd if=/dev/zero of="$FLOPPY_IMG" bs=512 count=2880 status=none

# Write boot sector (sector 0)
dd if="$BOOT_BIN" of="$FLOPPY_IMG" bs=512 count=1 conv=notrunc status=none

# If kernel.bin exists, write it starting at sector 1
if [ -f "$KERNEL_BIN" ]; then
  echo "Writing kernel.bin to sector 1"
  dd if="$KERNEL_BIN" of="$FLOPPY_IMG" bs=512 seek=1 conv=notrunc status=none
fi

echo "Floppy image ready: $FLOPPY_IMG"