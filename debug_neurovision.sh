#!/bin/bash
# Enhanced debugging script for NeuroVision

echo "🧠 Starting NeuroVision with enhanced debugging..."

# Run with all debugging flags
godot \
  --verbose \
  --debug \
  --debug-collisions \
  --debug-navigation \
  --print-fps \
  --gpu-validation \
  2>&1 | tee debug_output.log

# Additional debugging options:
# --remote-debug <address>    # For remote debugging
# --debug-shader-fallbacks    # Debug shader compilation
# --dump-gdextension-interface # Debug GDExtension issues
# --dump-extension-api       # Debug extension API