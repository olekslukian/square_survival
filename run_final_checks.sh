#!/bin/bash
set -e

echo "====== DART ANALYZE ======"
cd packages/game_core && dart analyze 2>&1 | tail -1
cd ../game_server && dart analyze 2>&1 | tail -1
cd ../game_client && dart analyze 2>&1 | tail -1

echo ""
echo "====== FLUTTER ANALYZE ======"
cd ../../apps/flutter_app && flutter analyze 2>&1 | tail -1

echo ""
echo "====== UNIT TESTS ======"
cd ../../packages/game_client && dart test 2>&1 | grep "passed"
cd ../../apps/flutter_app && flutter test 2>&1 | grep "passed"
