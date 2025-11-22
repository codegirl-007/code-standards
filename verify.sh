#!/bin/bash

# Verification script for code-improver.nvim plugin

echo "🔍 Verifying code-improver.nvim plugin structure..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check counter
checks_passed=0
checks_failed=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $1 (missing)"
        ((checks_failed++))
    fi
}

# Function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $1/ (missing)"
        ((checks_failed++))
    fi
}

echo "📁 Directory Structure:"
check_dir "lua/code-improver"
check_dir "plugin"
check_dir "doc"
check_dir "docs/standards"
check_dir "test-examples"
echo ""

echo "📄 Core Plugin Files:"
check_file "lua/code-improver/init.lua"
check_file "lua/code-improver/config.lua"
check_file "lua/code-improver/api.lua"
check_file "lua/code-improver/ui.lua"
check_file "lua/code-improver/standards.lua"
check_file "plugin/code-improver.lua"
echo ""

echo "📚 Documentation:"
check_file "README.md"
check_file "INSTALLATION.md"
check_file "doc/code-improver.txt"
check_file "LICENSE"
echo ""

echo "🧪 Test Materials:"
check_file "test-examples/sample.lua"
check_file "test-examples/TESTING.md"
check_file "docs/standards/lua-style-guide.md"
check_file "docs/standards/neovim-plugin-standards.md"
echo ""

echo "📋 Additional Files:"
check_file ".gitignore"
check_file "PROJECT_SUMMARY.md"
echo ""

# Check Lua syntax
echo "🔧 Checking Lua syntax..."
for file in lua/code-improver/*.lua plugin/*.lua; do
    if [ -f "$file" ]; then
        if lua -e "dofile('$file')" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $file syntax OK"
            ((checks_passed++))
        else
            # Many files won't run standalone, just check they parse
            if luac -p "$file" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} $file syntax OK"
                ((checks_passed++))
            else
                echo -e "${RED}✗${NC} $file has syntax errors"
                ((checks_failed++))
            fi
        fi
    fi
done
echo ""

# Summary
echo "=================================="
echo "Summary:"
echo -e "${GREEN}✓ Passed:${NC} $checks_passed"
echo -e "${RED}✗ Failed:${NC} $checks_failed"
echo "=================================="

if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Plugin is ready.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please review.${NC}"
    exit 1
fi

