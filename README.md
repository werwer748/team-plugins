# team-plugins

팀이 함께 쓰는 [Claude Code](https://claude.com/claude-code) 플러그인 마켓플레이스입니다.

| 플러그인 | 스킬 | 하는 일 |
|---|---|---|
| `wiki` | `/wiki-ingest`, `/wiki-query`, `/wiki-lint` | LLM Wiki vault(`raw/` + `wiki/`) 운영 |
| `ai-readiness-score` | `/ai-readiness-score` | repo의 AI 에이전트 준비도를 100점 만점으로 채점 |
| `harness` | `/harness:harness`, `/harness:review` | docs 기반으로 구현을 step으로 쪼개 순차 실행하고 리뷰 |

`ai-readiness-score`는 [원본 repo](https://github.com/werwer748/ai-readiness-score)를 그대로 참조합니다. `harness`는 [jha0313/harness_framework](https://github.com/jha0313/harness_framework)를 플러그인으로 옮긴 것입니다.

## 설치

```bash
claude plugin marketplace add werwer748/team-plugins
claude plugin install wiki@team-plugins
claude plugin install ai-readiness-score@team-plugins
claude plugin install harness@team-plugins
```

## 사용법

### wiki

`raw/`와 `wiki/` 폴더가 있는 vault에서 Claude Code를 열고:

```
/wiki-ingest raw/2026-03-04-kickoff-meeting.md     # 소스 하나를 위키에 반영
/wiki-ingest raw/2026-03-04-kickoff-meeting.md 바로 진행   # 요점 확인 단계 생략
/wiki-query 가격 정책이 어떻게 바뀌었지?            # 위키를 근거로 답변
/wiki-lint                                          # 모순, 깨진 링크, 미처리 소스 등 점검
```

말로 해도 됩니다: *"raw/xxx.md ingest 해줘"*, *"lint 해줘"*.

페이지 규칙은 [`plugins/wiki/skills/wiki-schema/SKILL.md`](plugins/wiki/skills/wiki-schema/SKILL.md)에 있고, 세 스킬이 시작할 때 불러 씁니다. vault의 `CLAUDE.md`에 다른 규칙이 있으면 그쪽이 우선합니다.

### ai-readiness-score

채점할 repo에서:

```
/ai-readiness-score              # 전체 실행
/ai-readiness-score quick        # 에이전트 프로브 생략 (95점 만점)
```

Python 3.8+가 필요합니다. 자세한 내용은 [원본 README](https://github.com/werwer748/ai-readiness-score/blob/main/README.ko.md)를 보세요.

### harness

작업할 프로젝트 루트에서:

```
/harness:harness     # docs 탐색 → 논의 → step 설계 → phases/ 파일 생성 → 실행
/harness:review      # 변경 사항을 CLAUDE.md·ARCHITECTURE·ADR 기준으로 점검
```

프로젝트에 `docs/`가 없으면 첫 실행 때 템플릿(`CLAUDE.md`, `docs/`, `.claude/settings.json`, `.gitignore`)을 복사합니다. `{...}` 자리를 채운 뒤 다시 실행하세요.

step 실행기(`execute.py`)는 Python 3와 `claude` CLI가 필요합니다. step마다 `claude -p --dangerously-skip-permissions`로 권한 확인 없이 실행하고 `feat-{task-name}` 브랜치에 자동 커밋하므로, 믿을 수 있는 프로젝트에서만 쓰세요.

## 업데이트

```bash
claude plugin marketplace update team-plugins
claude plugin update wiki@team-plugins
claude plugin update ai-readiness-score@team-plugins
claude plugin update harness@team-plugins
```
