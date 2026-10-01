# team-plugins

팀이 함께 쓰는 [Claude Code](https://claude.com/claude-code) 플러그인 마켓플레이스입니다.

| 플러그인 | 스킬 | 하는 일 |
|---|---|---|
| `wiki` | `/wiki-ingest`, `/wiki-query`, `/wiki-lint` | LLM Wiki vault(`raw/` + `wiki/`) 운영 |
| `ai-readiness-score` | `/ai-readiness-score` | repo의 AI 에이전트 준비도를 100점 만점으로 채점 |

`ai-readiness-score`는 [원본 repo](https://github.com/werwer748/ai-readiness-score)를 그대로 참조합니다.

## 설치

```bash
claude plugin marketplace add werwer748/team-plugins
claude plugin install wiki@team-plugins
claude plugin install ai-readiness-score@team-plugins
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

## 업데이트

```bash
claude plugin marketplace update team-plugins
claude plugin update wiki@team-plugins
claude plugin update ai-readiness-score@team-plugins
```
