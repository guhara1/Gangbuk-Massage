# Feel 마사지

서울 강북구에 특화된 출장마사지 예약 안내 사이트입니다.

## 사이트 방향

- 브랜드명: Feel 마사지
- 운영 범위: 서울 강북구 집중
- 주요 권역: 미아권역, 번동권역, 수유권역, 우이권역
- 운영 원칙: 광역 지역 나열이 아니라 강북구 생활권 중심의 고유 콘텐츠 구성

## 주요 파일

- `index.html`: 메인 페이지
- `gangbuk-gu/`: 강북구 및 지역별 안내 페이지
- `styles.css`: 전체 디자인
- `script.js`: 모바일 메뉴와 스크롤 reveal
- `favicon.svg`: 파비콘

## IndexNow / Sitemap

IndexNow 키 파일은 사이트 루트의 `87041de259bd4e94b8b60c79ddc77956.txt`입니다.

배포 도메인이 정해지면 GitHub 저장소 `Settings > Secrets and variables > Actions > Variables`에 아래 값을 추가하세요.

```text
SITE_URL=https://gangbuk-massage.pages.dev
```

수동 제출:

```powershell
$env:SITE_URL="https://gangbuk-massage.pages.dev"
./scripts/submit-indexnow.ps1 -All
```

사이트맵/robots 생성:

```powershell
$env:SITE_URL="https://gangbuk-massage.pages.dev"
./scripts/build-sitemap.ps1
```

GitHub Actions는 `main` 브랜치에 HTML 또는 SEO 파일이 변경되면 `SITE_URL` 값을 사용해 IndexNow에 전체 공개 URL을 제출합니다.

Google은 IndexNow에 참여하지 않으며 Google sitemap ping endpoint는 deprecated입니다. Google은 `robots.txt`의 `Sitemap:` 라인과 Google Search Console 사이트맵 제출로 처리하세요.

## 추후 교체할 정보

- 실제 사업자 정보
- 개인정보처리방침 URL
- 이용약관 URL
- 실제 운영 시간
- 실제 예약 채널
