#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-$HOME/.dotfiles/scripts/.config/scripts/python/taskwarrior}"
WRAPPER="${2:-$HOME/.dotfiles/scripts/.config/scripts/zsh/taskadd}"

echo "Installing TaskAdd v0.8 to:"
echo "  $TARGET"

mkdir -p "$TARGET"
rsync -a --delete \
  --exclude ".git" \
  --exclude "__pycache__" \
  ./ "$TARGET/"

chmod +x "$TARGET/taskadd.py"

echo "Creating zsh wrapper:"
echo "  $WRAPPER"
mkdir -p "$(dirname "$WRAPPER")"
cat > "$WRAPPER" <<EOF
#!/usr/bin/env zsh
exec python3 "$TARGET/taskadd.py" "\$@"
EOF
chmod +x "$WRAPPER"

echo
echo "Done."
echo
echo "Set your alias to the wrapper, not to python3 + wrapper:"
echo "  unalias taskaddpy 2>/dev/null || true"
echo "  alias taskaddpy='$WRAPPER'"
echo
echo "Test:"
echo "  taskaddpy preview --template hot-mercator --id Mercator --component Blueprint --worktype Planning --verb Build"
