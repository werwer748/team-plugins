# 프로젝트: 재고노트 (stock-note)

## 기술 스택
- Next.js 16 (App Router), 단일 Node 서버로 실행
- TypeScript strict mode
- Tailwind CSS 4
- Prisma + SQLite (Prisma는 정식 릴리스만 쓴다. rc 버전 금지)
- iron-session, bcryptjs (로그인 세션)
- web-push (발주일 알림)
- zod (요청 검증)
- Vitest (테스트)

## 아키텍처 규칙
- CRITICAL: 사용량은 DB에 저장하지 않는다. `src/lib/usage.ts`의 순수 함수로만 계산한다.
- CRITICAL: 모든 쓰기는 `src/app/api/` Route Handler를 거친다. Server Action을 쓰지 않는다.
- CRITICAL: 점주용 API는 세션의 매장으로만 데이터를 읽고 쓴다. 요청 본문이나 URL의 매장 id를 믿지 않는다.
- CRITICAL: 문의 버튼은 `src/app/layout.tsx` 한 곳에서만 렌더링한다. 페이지마다 따로 넣지 않는다. `/admin` 경로에서만 숨긴다.
- CRITICAL: 현재 월·일·요일은 `src/lib/date.ts`의 KST 함수로만 구한다. `new Date()`의 로컬 시간대에 의존하지 않는다.
- CRITICAL: 발주일 알림은 `OrderReminderLog`에 오늘 날짜를 기록한 뒤에만 보낸다. 같은 날 두 번 호출돼도 한 번만 발송한다.
- 품목은 `prisma/seed.ts`로만 관리한다. 품목 추가·수정 화면이나 API를 만들지 않는다.
- `src/lib/`은 DB와 네트워크에 접근하지 않는다. `src/services/`만 Prisma를 import한다.
- 컴포넌트는 `src/components/`에, 타입은 `src/types/`에 둔다.
- 화면 문구는 한국어로 쓴다.

## 개발 프로세스
- CRITICAL: 새 기능 구현 시 반드시 테스트를 먼저 작성하고, 테스트가 통과하는 구현을 작성할 것 (TDD)
- 커밋 메시지는 conventional commits 형식을 따를 것 (feat:, fix:, docs:, refactor:)

## 명령어
npm run dev      # 개발 서버
npm run build    # 프로덕션 빌드
npm run lint     # ESLint
npm run test     # 테스트
npx prisma migrate dev   # 스키마 변경 반영
npm run db:seed          # 품목 9종 + 첫 관리자 계정
