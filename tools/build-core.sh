#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./tools/verify-wrapper.sh
./gradlew --no-daemon --console=plain :shared:core:assembleRelease :shared:core:lintDebug :shared:core:testDebugUnitTest
python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as E
files=list(Path('shared/core/build/test-results/testDebugUnitTest').glob('TEST-*.xml'))
count=0
for file in files:
 root=E.parse(file).getroot();count+=int(root.get('tests',0))-int(root.get('skipped',0))
 if int(root.get('failures',0)) or int(root.get('errors',0)):raise SystemExit('Failed test report: '+str(file))
if count<45:raise SystemExit(f'Expected at least 45 shared tests, ran {count}')
print(f'Passed {count} actual shared-core tests')
PY
