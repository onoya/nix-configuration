#!/bin/bash
# Fix script for iTerm2 cask errors and Homebrew permission issues

set -e

echo "=== Fixing iTerm2 and Homebrew Issues ==="
echo ""

echo "Step 1: Fixing Homebrew tap permissions..."
if [ -d "/opt/homebrew/Library/Taps/homebrew/homebrew-cask" ]; then
    sudo chown -R $(whoami) /opt/homebrew/Library/Taps/homebrew/homebrew-cask
    echo "✓ Fixed homebrew-cask permissions"
else
    echo "✓ homebrew-cask directory not found (may have been removed)"
fi

echo ""
echo "Step 2: Updating Homebrew to fix outdated cask definitions..."
brew update || {
    echo "⚠️  Homebrew update failed, attempting to continue..."
}

echo ""
echo "Step 3: Manually removing iTerm2 if it exists..."
if brew list --cask | grep -q "iterm2"; then
    brew uninstall --cask iterm2 --force || {
        echo "⚠️  Failed to uninstall iTerm2 normally, trying with --zap..."
        brew uninstall --cask --zap iterm2 --force || echo "⚠️  Manual uninstall failed, will let nix-darwin handle it"
    }
    echo "✓ iTerm2 removed"
else
    echo "✓ iTerm2 not installed"
fi

echo ""
echo "Step 4: Updating Homebrew taps..."
brew update || echo "⚠️  Tap update had issues but continuing..."

echo ""
echo "Step 5: Cleaning up Homebrew..."
brew cleanup || echo "⚠️  Cleanup had issues but continuing..."

echo ""
echo "=== Fix complete! ==="
echo ""
echo "Now you can run:"
echo "  darwin-rebuild switch --flake ."
echo ""
echo "Or use the alias:"
echo "  rebuild"
