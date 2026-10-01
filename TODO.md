# TODO

## improve-token-efficiency 업그레이드

[jha0313/skills_repo](https://github.com/jha0313/skills_repo/tree/main/improve-token-efficiency)에서 옮겨 온 스킬을 하네스 비용 평가에 쓸 수 있게 다듬는 작업입니다. 위에서부터 순서대로 진행합니다.

스크립트 경로는 모두 `plugins/improve-token-efficiency/skills/improve-token-efficiency/` 기준입니다.

### 끝난 것

- [x] 경로에 `_`, `.`, 공백, 한글이 있는 repo에서 세션 폴더를 못 찾던 문제 수정 (`analyze_sessions.py`, `detect_patterns.py`)
- [x] `--entrypoint` 필터 추가. `sdk-cli`는 `claude -p`로 실행된 세션만, `cli`는 대화형 세션만 집계

### 1. 가격표 갱신

- [ ] `scripts/analyze_sessions.py`의 `PRICING`에 현재 모델(`claude-opus-5-5`, `claude-sonnet-5-5` 등) 행 추가. 가격은 공식 가격표에서 확인해서 넣는다.
- [ ] `scripts/detect_patterns.py`는 모델과 상관없이 낭비를 Opus 4 단가(`OPUS_READ`, `OPUS_W1H`, `OPUS_OUT`)로 계산한다. 세션의 실제 모델 단가를 쓰도록 바꾼다.
- [ ] `SKILL.md`의 "가격 기준" 표를 같이 고친다.

지금은 가격표에 없는 모델을 전부 Opus 4 가격으로 계산해서 금액을 믿을 수 없습니다.

검증: `harness_project`에서 실행했을 때 `[warn] unknown model` 경고가 나오지 않는다.

### 2. Read redundancy 점수 보정

- [ ] Read 호출이 0회인 세션은 이 항목을 100점으로 주지 말고 채점에서 빼거나 "측정 불가"로 표시한다 (`score_session`).
- [ ] 뺄 경우 나머지 세 항목의 가중치를 어떻게 다시 나눌지 정하고 `SKILL.md`의 Rubric 표에 적는다.

이 항목은 Read 도구 호출만 봅니다. 하네스 step 세션은 파일을 Bash로 읽어서(`harness_project` 기준 Bash 191회, Read 1회) 감점할 것이 안 보이고 자동으로 100점이 됩니다.

검증: `--entrypoint sdk-cli`로 돌린 결과에서 Read 0회인 세션의 `redundancy_score`가 100으로 나오지 않는다.

### 3. 패턴 탐지를 스킬 흐름에 연결

- [ ] `SKILL.md`의 동작 흐름에 `detect_patterns.py` → `build_patterns_dashboard.py` 단계를 추가한다.
- [ ] 사용자에게 주는 요약에 패턴별 추정 낭비를 포함한다.

두 스크립트가 들어 있지만 `SKILL.md`가 언급하지 않아서 스킬이 실행하지 않습니다.

검증: `/improve-token-efficiency`를 실행하면 효율 리포트와 패턴 리포트 HTML이 둘 다 만들어진다.

### 4. 문서에만 있는 옵션 정리

- [ ] `SKILL.md`가 안내하는 `--weights`, `--inline-chartjs`는 스크립트에 없다. 구현하거나 문서에서 지운다.

검증: `SKILL.md`에 나오는 옵션이 전부 스크립트의 `add_argument`에 있다.

### 5. 필터 적용 여부를 리포트에 표시

- [ ] `--entrypoint`로 걸러서 만든 결과인지 JSON의 `totals`에 기록한다.
- [ ] `build_dashboard.py`, `build_patterns_dashboard.py`가 그 값을 헤더에 보여 준다.

지금은 필터를 걸어도 대시보드에 표시가 없어서 전체 결과와 구분되지 않습니다.

검증: `--entrypoint sdk-cli`로 만든 HTML 헤더에 필터가 보인다.

### 6. 하네스 세션만 정확히 골라내기

- [ ] `sdk-cli`는 `claude -p`로 실행된 모든 세션이다. 하네스 step만 고르는 조건을 추가한다. `execute.py`가 보내는 첫 프롬프트("아래 step을 수행하세요")로 구분할 수 있다.
- [ ] step별(phase, step 번호) 비용을 묶어서 보여 줄지 정한다.

검증: 하네스 외 용도로 `claude -p`를 돌린 repo에서 하네스 step 세션만 집계된다.

### 7. 서브에이전트 로그 확인

- [ ] 스크립트는 세션 폴더 바로 아래의 `*.jsonl`만 읽는다. 하위 폴더의 서브에이전트 로그(`harness_project`에 2개)가 빠져 있다.
- [ ] 서브에이전트 토큰이 부모 세션 로그에 이미 들어 있는지 먼저 확인한다. 안 들어 있으면 합산하고, 들어 있으면 그대로 둔다.

검증: 서브에이전트를 쓴 세션의 비용이 실제 사용량과 맞는다.

### 8. 배포 전 정리

- [ ] 원본 repo에 라이선스가 없다. 팀 마켓플레이스로 재배포해도 되는지 jha0313에게 확인한다.
- [ ] `plugin.json`에 `version`을 넣는다. `claude plugin validate`가 `wiki`, `harness`, `improve-token-efficiency`에서 같은 경고를 낸다.

## harness에서 볼 것

- [ ] `harness_project`의 step 세션 10개가 전부 "캐시 활용 저조" 패턴으로 잡혔다(추정 낭비 $13.03, Opus 4 단가 기준). step마다 새 세션을 띄우는 구조 때문인지, 줄일 수 있는지 확인한다. 위 1번을 끝낸 뒤 다시 측정한다.
