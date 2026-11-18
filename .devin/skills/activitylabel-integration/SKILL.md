---
name: "activitylabel-integration"
description: "Use when the user asks to integrate the ActivityLabel Swift package into an iOS project, add it as an SPM dependency, or display LabelView with an image, title, activity indicator, or background."
---

# Интеграция ActivityLabel

`LabelView` — вертикальный `UIStackView`, объединяющий `UIImageView`,
`UILabel` и встроенный `UIActivityIndicatorView`. Содержимое анимируется
как единое целое.

## Когда использовать

- Пользователь просит подключить пакет ActivityLabel к проекту или таргету.
- Пользователь просит показать метку с изображением, текстом, индикатором
  загрузки или фоном.

## Подключение пакета

Минимальная iOS — 15.0, Swift — 5.9. Если ActivityLabel подключается
как локальный пакет, добавить в `Package.swift` потребителя:

```swift
dependencies: [
    .package(path: "../ActivityLabel")
],
targets: [
    .target(
        name: "AppTarget",
        dependencies: [.product(name: "ActivityLabel", package: "ActivityLabel")]
    )
]
```

Для Xcode-проекта — File > Add Package Dependencies > локальный путь
или git URL, таргету добавить продукт `ActivityLabel`.

## Базовое использование

```swift
import ActivityLabel

let labelView = LabelView(
    imageSystemName: "play.circle.fill",
    title: "Воспроизведение"
)
labelView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(labelView)
```

Размеры `imageView` задаются ограничениями (например 48×48),
метка центрируется и растягивается по содержимому.

## Настройка внешнего вида

```swift
labelView.textColor = .label
labelView.font = .systemFont(ofSize: 14, weight: .medium)
labelView.imageContentMode = .scaleAspectFit
labelView.spacing = 8
labelView.directionalContentInsets = NSDirectionalEdgeInsets(
    top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0
)
```

## Фон

`background` принимает `UIBackgroundConfiguration?`, как у
`UIButton.Configuration.background`. Значение `nil` отключает фон.
Настройки применяются к `layer` метки и анимируются
в `UIView.animate`.

```swift
var background = UIBackgroundConfiguration.clear()
background.backgroundColor = .secondarySystemFill
background.cornerRadius = 12.0
background.strokeColor = .systemGray3
background.strokeWidth = 1.0
labelView.background = background
```

Поддерживаются цвет, `cornerRadius`, обводка и тень (iOS 18+).
Не поддерживаются `backgroundInsets`, `visualEffect`, `image`,
`customView`.

## Управление состоянием

```swift
// Показать / сменить содержимое с анимацией
labelView.show(imageSystemName: "pause.circle.fill", title: "Пауза", animated: true)

// Скрыть
labelView.hide(animated: true)

// Индикатор загрузки
labelView.startActivityAnimating()
labelView.stopActivityAnimating()

// Очистить содержимое
labelView.clear()
```

Длительность анимаций — свойство `animationDuration` (по умолчанию 0.3).

## Проверка

Сборка пакета только под iOS — `swift build` падает на macOS
(нет UIKit). Проверять так:

```bash
xcodebuild -scheme ActivityLabel \
  -destination 'generic/platform=iOS Simulator' build

xcodebuild -scheme ActivityLabel \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Рабочий пример интеграции — `ActivityLabelDemo/ActivityLabelDemo/ViewController.swift`.
