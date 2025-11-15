set -ex

cd /app/src || exit 2

shopt -s globstar

# --- Define Variables ---
BOOT_ASM="boot.asm"
BOOT_BIN="/app/boot.bin"
KERNEL_BIN="/app/kernel.bin"
LINKER_SCRIPT="/app/build_tools/kernel.ld"
FLOPPY_IMG="/app/floppy.img"

# Clean artifacts
rm -f "$FLOPPY_IMG" "$BOOT_BIN" "$KERNEL_BIN"
rm -f *.o *.bin 2>/dev/null || true

# --- Assembly: Stage 1 (boot.asm) ---
if [ ! -f "$BOOT_ASM" ]; then
    echo "Error: Required file 'boot.asm' not found in src/."
    exit 3
fi

echo "==== Assembling BOOTLOADER: $BOOT_ASM ===="
nasm -f bin "$BOOT_ASM" -o "$BOOT_BIN"
echo "Produced boot sector: $BOOT_BIN"

# --- Assembly: Stage 2 (All other .asm files) ---
KERNEL_OBJS=""

for f in **/*.asm; do
  # Skip the bootloader file
  if [ "$(basename "$f")" = "$BOOT_ASM" ]; then
    continue
  fi

  echo "==== Assembling KERNEL/GAME component: $f ===="
  # 1. Strip the .asm suffix
  stem="${f%.asm}"  # e.g., 'src/game/player'
  # 2. Replace all forward slashes (/) with underscores (_)
  unique_base="${stem//\//_}"
  obj="${unique_base}.o" # e.g., 'src_game_player.o'

  nasm -f elf "$f" -o "$obj" # Assemble as ELF
  KERNEL_OBJS="$KERNEL_OBJS $obj"
done

# Concatenate all kernel/game components into kernel.bin
if [ -n "$KERNEL_OBJS" ]; then
    echo "==== Linking KERNEL: Using ld and $LINKER_SCRIPT ===="

    if [ ! -f "$LINKER_SCRIPT" ]; then
        echo "Error: Linker script 'kernel.ld' is missing in src/. Cannot link."
        exit 4
    fi

    # The actual linking command
    ld -m elf_i386 -T "$LINKER_SCRIPT" $KERNEL_OBJS -o "$KERNEL_BIN" --oformat binary
    echo "Produced linked kernel/game binary: $KERNEL_BIN"
fi

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