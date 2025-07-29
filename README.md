# 2025-C4-M13-Visionable
![깃허브리드미](https://github.com/user-attachments/assets/71a4a7de-e77a-4276-9c9a-b25ef7de27cb)
> 어비전스: 다이버시티 / 비전파서블 / 수수수 수퍼비전 / 어벤져스: The 6th Vision / See Different

- Apple Developer Acaemy @ POSTECH | Cohort 2025 | Challenge 4
- Period: 2025.06.28 - 2025.08.01 (30 Days)
- Development Environment : `iOS 26.0+` `Xcode 26.0+` `Swift 6`

<br>

## 👀 Team Visionable:
| <img width="150" height="150" alt="여니 미모지" src="https://github.com/user-attachments/assets/4aaf350b-7d09-4234-a60a-9dd47d399d57" /> <br> Yeony <br> [@youryeony](https://github.com/youryeony) | <img width="150" height="150" alt="쪼이 미모지" src="https://github.com/user-attachments/assets/dff69558-68fc-4c5d-afe9-4fe8b9bd3e97" />  <br> Joy <br> [@superbigjoy](https://github.com/superbigjoy) | <img width="150" height="150" alt="노우 미모지" src="https://github.com/user-attachments/assets/cd6c9311-92d1-458c-8dc4-3c16e71fb4ce" /> <br> Snow <br> [@Jikiim](https://github.com/Jikiim)| <img width="150" height="150" alt="후랑크 미모지" src="https://github.com/user-attachments/assets/11fd35ba-4c0e-4676-b6e0-a5cf7de52209"/> <br> Frank <br> [@chxhyxn](https://github.com/chxhyxn) | <img width="150" height="150" alt="잼 미모지" src="https://github.com/user-attachments/assets/5e7ccfe5-08cc-4064-9009-a97b413a716a" /> <br> Jam <br> [@jaminleee](https://github.com/jaminleee) | <img width="150" height="150" alt="미니 미모지" src="https://github.com/user-attachments/assets/e25d905b-66a8-496e-b044-a3deaf583c7a" /> <br> Mini <br> [@mini-min](https://github.com/mini-min) | 
| :--: | :--: | :--: | :--: | :--: | :--: |

<br>

## 📦 Frameworks
| Framework | Description |
|:-----:|-----|
| [**App Intents**](https://developer.apple.com/documentation/appintents) | 시스템 레벨에서 앱 기능을 자동으로 호출하기 위한 방법을 구현하는데 사용 |
| [**AVFoundation**](https://developer.apple.com/documentation/avfoundation) | 카메라, 이미지, 비디오, 실시간 프레임 처리 등 앱에서 사용하는 멀티미디어 기능 구현을 위해 사용 |
| [**Combine**](https://developer.apple.com/documentation/combine) | SwiftUI 스타일에 적합한 선언적 비동기 데이터 스트림 구현을 위해 사용 |
| [**Foundation Models**](https://developer.apple.com/documentation/foundationmodels) | 유사성 기반 이미지 검색 기반을 위해 온디바이스 LLM Model을 사용 |
| [**PhotoKit**](https://developer.apple.com/documentation/photokit?language=objc) | 하위 모듈인 Photos에 접근하기 위해 사용되는 상위 프레임워크. 사진 라이브러리 접근을 위해 사용 |
| [**Speech**](https://developer.apple.com/documentation/swiftdata) | 음성 인식을 통해 음성 검색 기능을 구현하기 위해 사용 |
| [**SwiftData**](https://developer.apple.com/documentation/swiftdata) | 로컬 DB, 최근 검색 기록/즐겨찾기 기능을 구현하기 위해 사용 |
| [**SwiftUI**](https://developer.apple.com/swiftui) | 선언적 UI 프레임워크 |
| [**Vision**](https://developer.apple.com/documentation/vision) | 텍스트 인식 (OCR)과 카메라 설정에서 사용하는 Vision Model을 활용하기 위해 사용 |
| [**WidgetKit**](https://developer.apple.com/documentation/vision) | 홈 화면에서 앱에 쉽게 접근할 수 있는 위젯 기능 구현을 위해 사용 |


<br>

## 📂 Foldering
```bash
├── .swiftlint
├── 📁 Resources
│   ├── Images
│   ├── Colors
│   ├── Fonts
│   ├── Localizable.xcstrings
├── 📁 Sources
|   ├── 🗂️ App
│   │   ├── FFIP_iOSApp.swift
│   │   ├── 🗂️ Coordinator
│   │   ├── 🗂️ Factory
|   ├── 🗂️ Components
│   ├── 🗂️ Data
│   ├── 🗂️ Extensions
│   ├── 🗂️ Modifers
│   ├── 🗂️ Presentation
│   │   ├── 🗂️ Camera
│   │   │   ├── CameraView.swift
│   │   │   ├── 🗂️ Model
│   │   │   ├── 🗂️ SubViews
│   │   ├── 🗂️ Search
│   │   ├── 🗂️ VoiceSearch
│   ├── 🗂️ Utils
``` 

<br>

## 📑 Tech Archives
- [**🍎 Coding Convention : Clean Code Swift**](https://posacademy.notion.site/Coding-Convention-Clean-Code-Swift-21f2b843d5af806f84a1fa8024ffa761?source=copy_link)   
: 마틴 아저씨의 클린 코드 원칙과 아카데미 컨벤션을 팀 수준에 맞게 적용하고, 그냥 남들이 사용하니까 사용하는 것이 아니라 "왜 사용해야하는지"에 대한 이해를 위한 정리 글

- [**😎 Vision Framework 공부하기**](https://posacademy.notion.site/Vision-21e2b843d5af80a78ab9ccd2e0a86f3d?source=copy_link)   
  : 유즈 케이스를 발산하기에 앞서, 팀원들의 Vision Framework 기술에 대한 이해와 싱크를 맞추기 위한 공부 내용
  
- [**🌠 Image Processing Flow**](https://posacademy.notion.site/2272b843d5af803db4f8ff6edc42b19c?source=copy_link)   
  : 핵심 기능을 구현하기 위해 필요한 실시간 스캐닝 -> 이미지 변환 -> 탐지 과정의 플로우를 정리하고, 그 과정에서 필요한 기술을 정리 
