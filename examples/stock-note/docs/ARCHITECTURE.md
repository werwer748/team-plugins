# 아키텍처

## 디렉토리 구조
```
prisma/
├── schema.prisma
└── seed.ts                # 품목 9종 + 첫 관리자 계정
public/
├── manifest.json          # 홈 화면에 추가 (iOS 웹 푸시 조건)
└── sw.js                  # push 이벤트를 받아 알림 표시
src/
├── app/               # 페이지 + API 라우트
│   ├── layout.tsx         # 문의 버튼을 렌더링하는 유일한 곳
│   ├── (owner)/           # 점주 영역. layout.tsx에 하단 탭
│   │   ├── page.tsx           # 홈: 사용량 조회, 발주일 배너
│   │   ├── counts/            # 월말 재고 입력
│   │   ├── receipts/          # 입고 기록
│   │   └── settings/          # 알림 켜기/끄기, 비밀번호 변경
│   ├── login/
│   ├── admin/             # 본사 영역
│   │   ├── inquiries/         # 문의 목록, 상태 변경
│   │   └── stores/            # 매장 계정 발급, 비밀번호 재설정
│   └── api/               # Route Handler (아래 API 표)
├── components/        # UI 컴포넌트
├── types/             # TypeScript 타입 정의
├── lib/               # 순수 함수. DB와 네트워크에 접근하지 않는다
│   ├── usage.ts           # 사용량 계산
│   └── date.ts            # KST 기준 월·일 문자열, 그 달의 일수, 요일
└── services/          # Prisma 조회·저장, 세션, 푸시 발송
```

## 패턴
- Server Components 기본. 폼, 문의 시트, 알림 설정처럼 인터랙션이 필요한 곳만 Client Component.
- 읽기: Server Component가 `services/` 함수를 직접 호출한다. 홈의 달 선택은 `?month=YYYY-MM` 검색 파라미터로 처리한다.
- 쓰기: 반드시 `app/api/` Route Handler를 거치고 JSON으로 주고받는다. Server Action은 쓰지 않는다 (ADR-003).
- 계층: `app/` → `services/` → `lib/`. 반대 방향으로 import하지 않는다.
- 검증: Route Handler가 요청 본문을 zod 스키마로 검증한 뒤 `services/`에 넘긴다.
- 권한: 각 레이아웃과 Route Handler가 `services/session`의 `requireOwner()`, `requireAdmin()`으로 확인한다. 점주 데이터는 항상 세션의 매장으로 조회한다.

## 데이터 모델
| 모델 | 주요 필드 | 제약 |
|------|------|------|
| Store | id, name | |
| User | id, loginId, passwordHash, role, storeId | loginId 유일. role은 OWNER 또는 ADMIN. OWNER는 storeId 필수 |
| Item | id, code, name, unit, sortOrder | code 유일. seed로만 생성 |
| StockCount | storeId, itemId, month, quantity | (storeId, itemId, month) 유일. month는 `YYYY-MM` |
| Receipt | id, storeId, itemId, date, quantity | date는 `YYYY-MM-DD` |
| PushSubscription | userId, endpoint, p256dh, auth | endpoint 유일 |
| OrderReminderLog | date, sentCount | date 유일. 같은 날 중복 발송을 막는다 |
| Inquiry | id, type, message, pagePath, storeId, contact, status, createdAt, handledAt | type은 INQUIRY 또는 COMPLAINT. status는 OPEN 또는 DONE. 비로그인 문의는 storeId가 없고 contact(매장명과 연락처)가 필수 |

사용량은 테이블이 없다. StockCount와 Receipt에서 매번 계산한다 (ADR-004).

수량은 실수로 저장하고, 계산 결과는 `lib/usage.ts`가 소수 첫째 자리로 반올림한다.

## 사용량 계산 (`lib/usage.ts`)
입력은 전월 말 재고, 당월 입고량 합계, 당월 말 재고, 그 달의 일수다. 결과는 아래 네 상태 중 하나다.

| 상태 | 조건 | 값 |
|------|------|------|
| ok | 아래 세 경우가 아니다 | 월 사용량, 하루 평균 |
| no-baseline | 전월 말 재고가 없다 | 없음 |
| no-closing | 당월 말 재고가 없다 | 없음 |
| check-needed | 계산한 월 사용량이 음수다 | 없음 |

## API
| 메서드와 경로 | 권한 | 설명 |
|------|------|------|
| POST /api/auth/login | 공개 | 아이디·비밀번호 확인 후 세션 쿠키 발급 |
| POST /api/auth/logout | 로그인 | 세션 삭제 |
| PUT /api/auth/password | 로그인 | 내 비밀번호 변경 |
| PUT /api/counts/[month] | 점주 | 그 달의 품목별 월말 재고를 한 번에 저장(있으면 덮어쓴다) |
| POST /api/receipts | 점주 | 날짜와 품목별 수량으로 입고 기록 생성 |
| PUT /api/receipts/[id] | 점주 | 입고 기록 수정 |
| DELETE /api/receipts/[id] | 점주 | 입고 기록 삭제 |
| POST /api/inquiries | 공개 | 문의 저장. 로그인 상태면 세션의 매장을 붙이고, 아니면 contact 필수 |
| POST /api/push/subscriptions | 점주 | 푸시 구독 저장 (알림 켜기) |
| DELETE /api/push/subscriptions | 점주 | 푸시 구독 삭제 (알림 끄기) |
| POST /api/cron/order-reminder | Bearer CRON_SECRET | 발주일 알림 발송 |
| PATCH /api/admin/inquiries/[id] | 관리자 | 문의 상태 변경 |
| POST /api/admin/stores | 관리자 | 매장과 점주 계정 생성 |
| PUT /api/admin/stores/[id]/password | 관리자 | 점주 비밀번호 재설정 |

React Native 앱을 만들 때 읽기용 GET 라우트를 `services/` 함수 위에 얇게 추가한다. MVP에는 만들지 않는다.

## 데이터 흐름
```
월말 재고 → 사용량
점주 → counts 폼(Client Component) → PUT /api/counts/[month] → services → SQLite
홈(Server Component) → services가 전월 말 재고·당월 입고 합계·당월 말 재고 조회
  → lib/usage 계산 → 품목별 표

발주일 알림
서버 crontab(수·목 09:00 KST) → POST /api/cron/order-reminder
  → 오늘(KST)이 수요일·목요일이 아니면 종료
  → OrderReminderLog에 오늘 날짜 기록 (이미 있으면 종료)
  → 모든 PushSubscription에 web-push 발송, 404·410 응답을 받은 구독은 삭제
  → public/sw.js가 알림 표시

문의
점주 → 문의 버튼(app/layout.tsx) → 시트 폼 → POST /api/inquiries (현재 경로 자동 첨부)
  → Inquiry 저장 → 본사 /admin/inquiries 목록 → PATCH로 처리완료
```

## 상태 관리
- 서버 상태는 Server Components가 요청마다 조회한다. 쓰기가 끝나면 `router.refresh()`로 다시 읽는다.
- 폼 입력값, 문의 시트 열림 여부 같은 클라이언트 상태는 `useState`로 둔다.
- 전역 상태 라이브러리와 클라이언트 캐시 라이브러리는 쓰지 않는다.

## 환경 변수
| 이름 | 용도 |
|------|------|
| DATABASE_URL | SQLite 파일 경로 |
| SESSION_SECRET | 세션 쿠키 암호화 키 |
| VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY | 웹 푸시 서명 키 |
| CRON_SECRET | 알림 발송 라우트 호출 비밀값 |
| ADMIN_LOGIN_ID, ADMIN_PASSWORD | seed가 만드는 첫 관리자 계정 |
