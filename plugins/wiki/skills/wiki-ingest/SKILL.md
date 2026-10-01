---
name: wiki-ingest
description: LLM Wiki vault(`raw/`와 `wiki/` 폴더가 있는 곳)에서 raw 소스 파일 하나를 위키에 반영한다. source 요약 페이지를 쓰고, 언급된 entity·concept 페이지를 만들거나 갱신하고, overview·index·log를 기록한다. 사용자가 "raw/xxx.md ingest 해줘", "이 소스 위키에 넣어줘", "새 회의록 반영해줘", "ingest this source"라고 하거나 raw/에 새 파일을 넣었다고 할 때 쓴다. `raw/`와 `wiki/`가 없는 폴더에서는 쓰지 않는다.
argument-hint: "[raw 파일 경로] [바로 진행]"
---

# wiki-ingest

raw 소스 파일 하나를 읽어 위키에 반영한다.

## 시작 전에

1. **vault 확인.** 현재 폴더에 `raw/`와 `wiki/`가 있는지 본다. 없으면 여기는 위키 vault가 아니라고 알리고, 이 폴더에 구조를 새로 만들지 묻는다. 답을 받기 전에는 아무것도 만들지 않는다.
2. **규칙 읽기.** Skill 도구로 `wiki:wiki-schema`를 불러온다. 페이지 규칙, frontmatter, 템플릿, index·log 형식이 거기 있고, 아래 단계는 전부 그 규칙을 따른다.
3. **대상 파일.** 인자로 받은 raw 파일이 대상이다. 인자가 없으면 `raw/`에서 `wiki/log.md`에 ingest 기록이 없는 파일을 보여주고 어느 것을 할지 묻는다.

## 절차

1. `wiki/log.md`에서 이미 ingest한 파일인지 확인한다. 이미 했다면 다시 할지 사용자에게 묻는다.
2. raw 파일을 끝까지 읽는다.
3. 핵심 요점 3~5개를 사용자에게 먼저 보여주고 강조할 점이 있는지 묻는다. 사용자가 "바로 진행"이라고 했으면 생략한다.
4. `wiki/sources/`에 요약 페이지를 쓴다.
5. 언급된 entity·concept마다 기존 페이지가 있으면 갱신하고, 없으면 만든다. 새 페이지를 만들기 전에 기존 파일명과 `aliases`를 검색해 중복을 막는다. 새 정보가 기존 내용과 다르면 schema의 "바뀌는 사실"과 "모순" 규칙을 따른다.
6. 현재 상태가 바뀌었으면 `wiki/overview.md`를 갱신한다.
7. `wiki/index.md`를 갱신한다.
8. `wiki/log.md`에 항목을 추가한다. raw 파일 링크를 꼭 넣는다.
9. 사용자에게 보고한다: 생성·수정한 페이지 목록, 발견한 갱신과 모순.

`raw/` 안의 파일은 읽기만 한다. 수정·이동·삭제하지 않는다.
