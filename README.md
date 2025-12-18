<p align="center">
  <img src="icon_zpl_designer.ico" alt="ZPL Designer Logo" width="128" height="128">
</p>

<h1 align="center">ZPL Designer</h1>

<p align="center">
  <strong>Zebra 라벨 프린터용 ZPL 코드를 시각적으로 디자인하는 GUI 도구</strong>
</p>

<p align="center">
  <a href="#주요-기능">주요 기능</a> •
  <a href="#설치-방법">설치</a> •
  <a href="#사용-방법">사용법</a> •
  <a href="#지원-요소">지원 요소</a> •
  <a href="#빌드">빌드</a>
</p>

---

## 소개

ZPL Designer는 Zebra Programming Language(ZPL) 라벨 코드를 시각적인 드래그 앤 드롭 인터페이스로 생성할 수 있는 Flutter 기반 애플리케이션입니다. 복잡한 ZPL 명령어를 직접 작성할 필요 없이, 캔버스에 요소를 배치하고 속성을 설정하면 자동으로 ZPL 코드가 생성됩니다.

## 주요 기능

- **시각적 라벨 디자인**: 드래그 앤 드롭으로 라벨 요소 배치
- **실시간 미리보기**: Labelary API를 통한 ZPL 코드 미리보기
- **다양한 요소 지원**: 텍스트, 박스, 라인, 바코드, QR 코드
- **ZPL 코드 가져오기/내보내기**: 기존 ZPL 코드 편집 및 새 코드 생성
- **다중 DPMM 지원**: 6, 8, 12, 24 dpmm 프린터 해상도 지원
- **레이어 관리**: 요소의 Z-Index 조절 및 레이어 패널
- **그리드 시스템**: mm 단위 그리드 표시로 정밀한 배치
- **키보드 단축키**: Delete, Ctrl+Z (Undo), Ctrl+Y (Redo), ESC

## 설치 방법

### 사전 요구사항

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.32.0 이상
- Dart SDK 3.8.0 이상

### 의존성 설치

```bash
# 저장소 클론
git clone <repository-url>
cd zpl_designer

# 의존성 설치
flutter pub get
```

## 사용 방법

### 애플리케이션 실행

```bash
# Chrome 브라우저에서 실행 (웹)
flutter run -d chrome

# Windows 앱으로 실행
flutter run -d windows
```

### 기본 사용법

1. **캔버스 설정**: 상단 바에서 라벨 크기(mm)와 DPMM 해상도를 설정합니다.

2. **요소 추가**: 좌측 도구 사이드바에서 원하는 요소를 캔버스로 드래그합니다.
   - 텍스트 (T)
   - 박스
   - 라인
   - 바코드
   - QR 코드

3. **요소 편집**:
   - 요소를 클릭하여 선택
   - 드래그로 위치 이동
   - 핸들을 드래그하여 크기 조절
   - 우측 속성 패널에서 상세 속성 편집

4. **레이어 관리**: 하단 레이어 패널에서 요소 순서 및 선택 관리

5. **ZPL 내보내기**: 상단 바의 "Export ZPL" 버튼 클릭

6. **미리보기**: 상단 바의 "Preview" 버튼으로 실제 출력 미리보기

### 키보드 단축키

| 단축키 | 기능 |
|--------|------|
| `Delete` / `Backspace` | 선택된 요소 삭제 |
| `Ctrl + Z` | 실행 취소 (Undo) |
| `Ctrl + Y` | 다시 실행 (Redo) |
| `ESC` | 선택 해제 |

## 지원 요소

### 텍스트 (Text)

| 속성 | 설명 |
|------|------|
| 텍스트 내용 | 표시할 문자열 |
| 폰트 | A0 ~ V까지 ZPL 기본 폰트 |
| 폰트 높이/너비 | 글자 크기 (dots) |
| 최대 줄 수 | 텍스트 줄바꿈 설정 |
| 정렬 | 왼쪽/가운데/오른쪽/양쪽 |
| 회전 | 0°, 90°, 180°, 270° |
| 테두리 | 테두리 표시 및 두께 |

### 바코드 (Barcode)

| 지원 타입 | ZPL 명령어 |
|-----------|------------|
| Code 128 | ^BC |
| Code 39 | ^B3 |
| EAN-13 | ^BE |
| UPC-A | ^BU |

**속성**: 데이터, 모듈 너비, 높이, 텍스트 표시, 회전

### QR 코드 (QR Code)

| 속성 | 설명 |
|------|------|
| 데이터 | 인코딩할 내용 (URL, 텍스트 등) |
| 배율 | 1~10 크기 배율 |
| 오류 정정 | L(7%), M(15%), Q(25%), H(30%) |
| 회전 | 0°, 90°, 180°, 270° |

### 박스 (Box)

그래픽 박스 요소 (^GB 명령어)
- 위치 및 크기
- 테두리 두께

### 라인 (Line)

가로/세로 라인 요소
- 위치 및 길이
- 두께

## DPMM (Dots Per MM) 설정

프린터 해상도에 맞는 DPMM을 선택하세요:

| DPMM | DPI | 일반적인 사용처 |
|------|-----|-----------------|
| 6 dpmm | 152 dpi | 저해상도 프린터 |
| 8 dpmm | 203 dpi | 일반 라벨 프린터 |
| 12 dpmm | 305 dpi | 고해상도 프린터 |
| 24 dpmm | 610 dpi | 초고해상도 프린터 |

## 빌드

### 웹 빌드

```bash
flutter build web
```

빌드 결과물은 `build/web` 디렉토리에 생성됩니다.

### Windows 빌드

```bash
flutter build windows
```

빌드 결과물은 `build/windows/x64/runner/Release` 디렉토리에 생성됩니다.

## 프로젝트 구조

```
lib/
├── core/                      # 핵심 클래스
│   ├── app_theme.dart         # 앱 테마 설정
│   ├── base_canvas_element.dart   # 캔버스 요소 기본 클래스
│   ├── base_canvas_item.dart      # 캔버스 위젯 기본 클래스
│   ├── dpmm.dart              # DPMM 해상도 관리
│   └── zpl_parser.dart        # ZPL 코드 파서
├── provider/                  # 상태 관리
│   ├── canvas_config_provider.dart  # 캔버스 설정
│   └── editor_state_provider.dart   # 에디터 상태
├── view/
│   ├── design_view.dart       # 메인 디자인 뷰
│   ├── item/                  # 캔버스 요소들
│   │   ├── text/              # 텍스트 요소
│   │   ├── box/               # 박스 요소
│   │   ├── line/              # 라인 요소
│   │   ├── barcode/           # 바코드 요소
│   │   └── qrcode/            # QR 코드 요소
│   ├── panels/                # UI 패널
│   │   ├── top_bar.dart       # 상단 바
│   │   ├── tool_sidebar.dart  # 도구 사이드바
│   │   ├── properties_panel.dart  # 속성 패널
│   │   ├── layers_panel.dart  # 레이어 패널
│   │   └── status_bar.dart    # 상태 바
│   ├── tools/                 # 도구 관련
│   └── widget/                # 공통 위젯
│       ├── canvas_grid.dart   # 그리드 오버레이
│       ├── zpl_export_dialog.dart   # ZPL 내보내기 다이얼로그
│       ├── zpl_import_dialog.dart   # ZPL 가져오기 다이얼로그
│       └── zpl_preview_dialog.dart  # 미리보기 다이얼로그
└── main.dart                  # 앱 진입점
```

## 기술 스택

- **Framework**: Flutter 3.32+
- **State Management**: Provider
- **HTTP Client**: http 패키지
- **File Handling**: file_picker 패키지

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

<p align="center">
  Made with Flutter
</p>
