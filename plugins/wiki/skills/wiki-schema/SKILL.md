---
name: wiki-schema
description: LLM Wiki vault의 공통 규칙(디렉토리 구조, 페이지 규칙, frontmatter, 템플릿, index·log 형식). wiki-ingest, wiki-query, wiki-lint가 시작할 때 불러 쓴다. 사용자가 직접 호출하는 스킬이 아니다.
user-invocable: false
---

# LLM Wiki 스키마

Karpathy의 [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 패턴으로 운영하는 vault의 공통 규칙이다.
너(LLM)는 위키 관리자다. 사람은 소스를 모으고 질문한다. 요약, 상호참조, 정리, 기록은 전부 네가 한다.

## 우선순위

vault 루트의 `CLAUDE.md`에 위키 규칙이 있으면 그 규칙이 이 문서보다 우선한다. 이 문서는 `CLAUDE.md`가 정하지 않은 부분만 채운다.

## 디렉토리 구조

```
raw/              원본 소스. 읽기 전용. 절대 수정·이동·삭제하지 않는다.
wiki/
  index.md        전체 페이지 카탈로그 (ingest마다 갱신)
  log.md          작업 기록 (append-only)
  overview.md     현재 상태를 한 장으로 종합
  sources/        raw 파일 1개당 요약 페이지 1개
  entities/       사람, 회사, 제품 등 고유한 대상
  concepts/       개념, 지표, 기능, 의사결정 주제
  analyses/       query 답변 중 보존할 가치가 있는 것
```

## 페이지 규칙

- **언어**: vault의 기존 페이지가 쓰는 언어로 쓴다.
- **파일명**: 제목 그대로, vault의 언어로 쓴다 (`홍길동.md`, `이탈률.md`). source 페이지는 `YYYY-MM-DD 제목.md`. 특수 파일(index, log, overview)만 영문.
- **링크**: Obsidian 위키링크 `[[페이지명]]`. vault 전체에서 파일명이 겹치면 안 된다.
- **출처**: 모든 사실은 bullet이나 문단 끝에 source 페이지를 인용한다. 예: `([[2026-03-04 킥오프 회의]])`
- **별칭**: 같은 대상의 다른 표기(약칭, 이니셜, 별명)는 frontmatter `aliases`에 모은다. 새 페이지를 만들기 전에 기존 파일명과 aliases를 먼저 검색해서 중복을 막는다.
- **바뀌는 사실**(가격, 일정, 수치, 결정)은 덮어쓰지 않는다. "현재" 섹션에는 최신 값을 두고, 이전 값은 "이력" 섹션에 날짜와 출처와 함께 남긴다.
- **모순**: 소스끼리 충돌하면 한쪽을 고르지 말고 양쪽 출처를 달아 callout으로 표시한다.
  ```
  > [!warning] 모순
  > A 소스는 X라고 하고 B 소스는 Y라고 한다.
  ```
- 소스에 없는 내용을 추측으로 채우지 않는다. 모르면 "소스 없음"이라고 쓴다.

### frontmatter

```yaml
---
type: source | entity | concept | analysis | overview
aliases: []
sources: []        # 이 페이지의 근거가 된 source 페이지 링크
updated: YYYY-MM-DD
---
```

- source 페이지 추가 필드: `raw` (원본 링크), `date` (원본 작성일), `author`, `format`
- entity 페이지 추가 필드: `kind` (`person`, `company`, `product` 등. vault가 이미 쓰는 값이 있으면 그 값을 따른다)

### 페이지 템플릿

- **source**: 원본 링크와 메타 → 요약(3~5줄) → 핵심 내용 → 기존 위키와의 관계(새 정보 / 갱신 / 모순)
- **entity**: 한 줄 정의 → 현재 정보 → 타임라인(날짜순) → 관련 페이지
- **concept**: 정의 → 현재 상태 → 근거·맥락 → 이력(날짜순)

## index.md 형식

카테고리(Overview / Sources / Entities / Concepts / Analyses)별로 `- [[페이지]] — 한 줄 요약`. 맨 위에 최종 갱신일, 소스 수, 페이지 수를 적는다.

## log.md 형식

항목마다 `## [YYYY-MM-DD] 작업 | 대상`으로 시작한다(grep으로 파싱할 수 있게). 날짜는 원본 날짜가 아니라 작업한 날짜다. 그 아래 1~3줄로 무엇을 했는지 쓰고, ingest라면 raw 파일 링크를 꼭 넣는다.

```
## [2026-09-30] ingest | 2026-03-04 킥오프 회의
- raw: [[2026-03-04-kickoff-meeting]]
- 생성 17, 수정 0. 가격 가설 월 29,000원 기록.
```
