#!/usr/bin/env bash
# tdd-guard: PreToolUse 훅 (Write|Edit).
# 대응하는 테스트 파일이 없는 소스 파일의 수정을 거부한다.
#
# 검사 대상  .ts .tsx .js .jsx .mjs .cjs .py
# 테스트 인정  프로젝트 안 어디든 아래 이름의 파일이 있으면 통과
#   JS/TS   foo.test.*, foo.spec.*, __tests__/foo.*
#   Python  test_foo.py, foo_test.py
# 화이트리스트  아래 ALLOW + 프로젝트 루트의 .tdd-guard-allow
#   한 줄에 glob 패턴 하나, #으로 시작하면 주석.
#   프로젝트 루트 기준 상대 경로 또는 파일 이름과 비교하며, *는 /도 포함한다.

ALLOW=(
  # 테스트 파일
  '*.test.*' '*.spec.*' 'test_*.py' '*_test.py' 'conftest.py'
  '__tests__/*' '*/__tests__/*' 'tests/*' '*/tests/*' 'test/*' '*/test/*'
  # 설정·선언 파일
  '*.config.*' '*.d.ts' '.*' '__init__.py' 'setup.py'
)

command -v jq >/dev/null || { echo "tdd-guard: jq가 필요합니다" >&2; exit 1; }

input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
root=${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd' <<<"$input")}

# 프로젝트 밖 파일과 검사 대상이 아닌 확장자는 통과
case $file in "$root"/*) ;; *) exit 0 ;; esac
rel=${file#"$root"/}
base=${file##*/}
case $base in *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.py) ;; *) exit 0 ;; esac

# 화이트리스트
while read -r pattern || [ -n "$pattern" ]; do
  case $pattern in ''|'#'*) continue ;; esac
  [[ $rel == $pattern || $base == $pattern ]] && exit 0
done < <(printf '%s\n' "${ALLOW[@]}"; cat "$root/.tdd-guard-allow" 2>/dev/null)

# 테스트 파일 찾기
stem=${base%.*}
ext=${base##*.}
# [id].tsx 같은 이름을 find가 글자 그대로 찾도록 glob 문자를 이스케이프
name=$(sed 's/[][*?\\]/\\&/g' <<<"$stem")
if [ "$ext" = py ]; then
  tests=(-name "test_$name.py" -o -name "${name}_test.py")
  hint="test_$stem.py 또는 ${stem}_test.py"
else
  tests=(-name "$name.test.*" -o -name "$name.spec.*" -o -path "*/__tests__/$name.*")
  hint="$stem.test.$ext 또는 $stem.spec.$ext"
fi
found=$(find "$root" \
  \( -name node_modules -o -name .git -o -name .venv -o -name venv -o -name dist -o -name build \) -prune \
  -o -type f \( "${tests[@]}" \) -print -quit)
[ -n "$found" ] && exit 0

# 거부: reason은 Claude에게, systemMessage는 사용자에게 보인다
reason="TDD guard: $rel 에 대응하는 테스트 파일이 없어 수정을 거부했습니다. 먼저 테스트를 작성하세요 ($hint). 테스트가 필요 없는 파일이라면 .tdd-guard-allow 를 직접 고치지 말고, 사용자에게 이 이유를 알리고 패턴 추가를 요청하세요."
notice="TDD guard: $rel 수정을 막았습니다 (테스트 파일 없음). 할 일: 테스트를 먼저 만들거나 ($hint), 테스트가 필요 없는 파일이면 .tdd-guard-allow 에 패턴을 추가하세요."
jq -n --arg reason "$reason" --arg notice "$notice" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  },
  systemMessage: $notice
}'
