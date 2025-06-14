#!/usr/bin/env python3
"""Manual verification of color system implementation"""

import os
import re
import json

def verify_m3_design_tokens():
    """Verify M3DesignTokens.gd implementation"""
    print("\n=== Verifying M3DesignTokens.gd ===")
    
    with open("src/ui/themes/M3DesignTokens.gd", "r") as f:
        content = f.read()
    
    # Check for key constants
    checks = {
        "M3_COLORS dictionary": "const M3_COLORS",
        "BRAIN_STRUCTURE_COLORS dictionary": "const BRAIN_STRUCTURE_COLORS",
        "get_color method": "static func get_color",
        "get_semantic_color method": "static func get_semantic_color",
        "get_ui_color method": "static func get_ui_color",
        "has_token method": "static func has_token",
        "transparent color": '"transparent".*Color\\(0,\\s*0,\\s*0,\\s*0\\)'
    }
    
    for check_name, pattern in checks.items():
        if re.search(pattern, content):
            print(f"✓ {check_name} found")
        else:
            print(f"✗ {check_name} NOT found")

def verify_color_migrator():
    """Verify M3ColorMigrator.gd implementation"""
    print("\n=== Verifying M3ColorMigrator.gd ===")
    
    with open("src/ui/themes/M3ColorMigrator.gd", "r") as f:
        content = f.read()
    
    checks = {
        "find_closest_token method": "static func find_closest_token",
        "generate_migration_code method": "static func generate_migration_code",
        "ColorInstance class": "class ColorInstance",
        "BRAIN_STRUCTURE_COLORS reference": "BRAIN_STRUCTURE_COLORS"
    }
    
    for check_name, pattern in checks.items():
        if re.search(pattern, content):
            print(f"✓ {check_name} found")
        else:
            print(f"✗ {check_name} NOT found")

def verify_color_usage():
    """Check for migrated color usage in key files"""
    print("\n=== Verifying Color Migration in UI Files ===")
    
    files_to_check = [
        "src/ui/components/StructureInfoPanel.gd",
        "src/ui/components/QuizPanel.gd"
    ]
    
    for file_path in files_to_check:
        if os.path.exists(file_path):
            with open(file_path, "r") as f:
                content = f.read()
            
            # Check for M3DesignTokens usage
            m3_usage = len(re.findall(r'M3DesignTokens\.get_\w+color', content))
            hardcoded = len(re.findall(r'Color\([^)]+\)', content))
            
            print(f"\n{os.path.basename(file_path)}:")
            print(f"  ✓ M3DesignTokens usage: {m3_usage} instances")
            if hardcoded > 0:
                print(f"  ⚠ Hardcoded colors remaining: {hardcoded} instances")
            else:
                print(f"  ✓ No hardcoded colors found")
        else:
            print(f"\n✗ File not found: {file_path}")

def verify_test_files():
    """Check if unit test files exist"""
    print("\n=== Verifying Unit Test Files ===")
    
    test_files = [
        "tests/unit/test_m3_design_tokens_unit.gd",
        "tests/unit/test_m3_color_migrator_unit.gd",
        "tests/unit/test_color_system_unit_runner.gd"
    ]
    
    for test_file in test_files:
        if os.path.exists(test_file):
            print(f"✓ {os.path.basename(test_file)} exists")
        else:
            print(f"✗ {os.path.basename(test_file)} NOT found")

if __name__ == "__main__":
    print("=== COLOR SYSTEM MANUAL VERIFICATION ===")
    verify_m3_design_tokens()
    verify_color_migrator()
    verify_color_usage()
    verify_test_files()
    print("\n=== VERIFICATION COMPLETE ===")