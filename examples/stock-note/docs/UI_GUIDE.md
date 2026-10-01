# UI 디자인 가이드

## 디자인 원칙
1. 도구처럼 보여야 한다. 마케팅 페이지가 아니라 점주가 매장에서 매달 여는 장부다.
2. 한 손으로 숫자를 입력한다. 숫자 입력은 `inputmode="decimal"`, 누르는 영역은 높이 44px 이상, 한 행에 한 품목.
3. 숫자가 주인공이다. 사용량 숫자를 가장 크게 쓰고 장식을 두지 않는다.

## AI 슬롭 안티패턴 — 하지 마라
| 금지 사항 | 이유 |
|-----------|------|
| backdrop-filter: blur() | glass morphism은 AI 템플릿의 가장 흔한 징후 |
| gradient-text (배경 그라데이션 텍스트) | AI가 만든 SaaS 랜딩의 1번 특징 |
| "Powered by AI" 배지 | 기능이 아니라 장식. 사용자에게 가치 없음 |
| box-shadow 글로우 애니메이션 | 네온 글로우 = AI 슬롭 |
| 보라/인디고 브랜드 색상 | "AI = 보라색" 클리셰 |
| 모든 카드에 동일한 rounded-2xl | 균일한 둥근 모서리는 템플릿 느낌 |
| 배경 gradient orb (blur-3xl 원형) | 모든 AI 랜딩 페이지에 있는 장식 |

## 색상
라이트 모드 고정. 다크 모드는 만들지 않는다.

### 배경
| 용도 | 값 |
|------|------|
| 페이지 | bg-stone-50 (#fafaf9) |
| 카드 | bg-white (#ffffff) + border-stone-200 |

### 텍스트
| 용도 | 값 |
|------|------|
| 주 텍스트 | text-stone-900 |
| 본문 | text-stone-700 |
| 보조 | text-stone-500 |
| 비활성 | text-stone-400 |

### 데이터/시맨틱 색상
| 용도 | 값 |
|------|------|
| 포인트 (주요 버튼, 현재 탭, 발주일 배너) | emerald-700 (#047857) |
| 확인 필요 | amber-700 (#b45309) |
| 에러, 삭제 | red-600 (#dc2626) |
| 중립/기본 | stone-500 (#78716c) |

색만으로 상태를 구분하지 않는다. "확인 필요", "월말 재고 입력 필요"처럼 항상 문구를 함께 쓴다.

## 컴포넌트
### 카드
```
rounded-lg bg-white border border-stone-200 p-4
```

### 버튼
```
Primary:   h-12 w-full rounded-lg bg-emerald-700 text-white font-medium active:bg-emerald-800 disabled:bg-stone-300
Secondary: h-12 rounded-lg border border-stone-300 bg-white text-stone-900 active:bg-stone-100
Text:      text-stone-500 hover:text-stone-700
```

### 입력 필드
```
h-12 w-full rounded-lg border border-stone-300 bg-white px-3 text-lg focus:border-emerald-700 focus:outline-none
숫자 입력: 위 스타일 + text-right tabular-nums, inputmode="decimal"
```

### 품목 행
```
flex items-center justify-between gap-3 py-2
왼쪽: 품목명(text-base text-stone-900) + 단위(text-sm text-stone-500)
오른쪽: 숫자 입력 w-28
```

### 사용량 표
```
열: 품목 | 월 사용량 | 하루 평균
숫자 열은 text-right tabular-nums, 행 구분은 border-b border-stone-200
계산할 수 없는 행은 숫자 대신 안내 문구를 두 열에 걸쳐 쓴다
```

### 발주일 배너
```
rounded-lg border border-emerald-700 bg-emerald-50 p-4 text-emerald-900
```

### 하단 탭
```
fixed bottom-0 inset-x-0 h-14 bg-white border-t border-stone-200
탭 4개: 홈 · 월말 재고 · 입고 · 설정
현재 탭 text-emerald-700, 나머지 text-stone-500
```

### 문의 버튼과 시트
```
버튼: fixed right-4 bottom-20 h-12 px-4 rounded-full bg-stone-900 text-white text-sm (아이콘 + "문의")
      하단 탭이 없는 로그인 페이지에서는 bottom-4
시트: fixed inset-x-0 bottom-0 rounded-t-xl bg-white p-4, 뒤 배경 bg-black/40
      유형 선택(문의/불만) → 내용 입력 → 보내기(Primary 버튼)
```

## 레이아웃
- 전체 너비: 점주 영역 max-w-md mx-auto, 본사 관리자 영역 max-w-4xl mx-auto
- 정렬: 좌측 정렬 기본. 숫자만 우측 정렬. 중앙 정렬 금지
- 간격: 좌우 px-4, 카드 사이 gap-3, 섹션 사이 space-y-6, 하단 탭에 가리지 않게 pb-24

## 타이포그래피
시스템 폰트를 쓴다. 웹 폰트를 내려받지 않는다.

| 용도 | 스타일 |
|------|--------|
| 페이지 제목 | text-xl font-semibold text-stone-900 |
| 카드 제목 | text-sm font-medium text-stone-500 |
| 본문 | text-base text-stone-700 leading-relaxed |
| 사용량 숫자 | text-2xl font-semibold tabular-nums text-stone-900 |

## 애니메이션
- 문의 시트 slide-up (0.2s). `prefers-reduced-motion`이면 끈다.
- 그 외 모든 애니메이션 금지

## 아이콘
- SVG 인라인, 24px, strokeWidth 1.5
- 하단 탭 아이콘은 항상 글자 라벨과 함께 쓴다
- 아이콘 컨테이너(둥근 배경 박스)로 감싸지 않는다
