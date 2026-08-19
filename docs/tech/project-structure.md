# Структура проекта

Документ описывает назначение каталогов и правила размещения новых файлов. Канонические правила разработки также зафиксированы в [Project Guidelines](../engineering/project-guidelines.md).

## Верхний уровень

```text
Compound Interest/
├── Compound Interest/
├── UnitTests/
├── docs/
├── scripts/
├── Compound Interest.xcodeproj/
└── README.md
```

- `Compound Interest/` — production-код приложения и ресурсы.
- `UnitTests/` — unit-тесты, зеркалирующие production-слои. Подробности отдельных тестов документация не описывает.
- `docs/` — проектная документация.
- `scripts/` — bootstrap, генерация проекта/ресурсов, lint, Fastlane и CI/deploy-инфраструктура.
- `Compound Interest.xcodeproj/` — Xcode-проект. По существующей документации и скриптам проект генерируется через XcodeGen.

## Production-код

```text
Compound Interest/
├── App/
├── Common/
├── Core/
├── Flows/
├── Infrastructure/
├── Model/
└── Resources/
```

### `App`

Содержит lifecycle и app entry point. Сейчас здесь находится `MainApp`, который конфигурирует Firebase, создаёт зависимости верхнего уровня и передаёт их в `RootView`.

### `Flows`

Содержит пользовательские flow и feature-specific UI.

- `Flows/App` — app-scoped UI-композиция, не относящаяся к отдельному бизнес-flow.
- `Flows/Main` — основной экран расчёта, view model, дочерние views и presentation-модели.
- `Flows/History` — экран истории и его view model.
- `Flows/Chart` — presentation-компоненты графика.

Правило проекта: flow с собственным состоянием использует `ViewModel`; дочерние views конкретного flow живут в `Views`, presentation-модели — в `Models`.

### `Model`

Содержит доменные и persistence-модели.

- `Model/Domain` — доменные типы расчёта и истории.
- `Model/Database` — SwiftData-модели, версия схемы и миграционный план.
- `Model/DTO` упоминается в гайдлайнах как место для сетевых транспортных моделей, но в текущем дереве не найден.

### `Infrastructure`

Содержит проектно-специфичные реализации внешних и локальных сервисов:

- `Infrastructure/History` — SwiftData-репозиторий истории и fallback-реализации.
- `Infrastructure/Analytics` — Firebase и Noop реализации аналитики.

### `Core`

Содержит переносимые сервисы и контракты, не завязанные на конкретный flow:

- `Core/Analytics` — `AnalyticsClient` и `AnalyticsEvent`.
- `Core/SwiftDataStore.swift` — тонкая обёртка над `ModelContainer.mainContext`.
- `Core/ApplicationSupportDirectory.swift` — работа с директорией Application Support.

### `Common`

Содержит переиспользуемые extensions, helpers и views:

- `Common/Extensions`
- `Common/Helpers`
- `Common/View`

Согласно гайдлайнам, сюда не помещаются presentation-свойства доменных моделей и feature-specific UI.

### `Resources`

Содержит assets, локализации, plist и сгенерированные ресурсы. Код в `Resources/Generated` не редактируется вручную.

## Документация

Текущая структура `docs/`:

```text
docs/
├── index.md
├── engineering/
│   ├── project-guidelines.md
│   ├── swift-style.md
│   └── swiftlint-rules.md
├── product/
│   ├── analytics.md
│   └── user-scenarios.md
└── tech/
    ├── architecture.md
    ├── project-structure.md
    ├── scripts.md
    └── technical-decisions.md
```

Новые документы следует добавлять только при появлении устойчивого знания. Не нужно создавать пустые файлы ради шаблона.

## Где фиксировать новое знание

- Изменение слоёв, зависимостей, потоков данных или persistence: обновить [архитектуру](architecture.md).
- Новое правило размещения файлов или SwiftUI-паттерн: обновить [Project Guidelines](../engineering/project-guidelines.md) и при необходимости этот документ.
- Изменение build, generation, CI или deploy: обновить [Scripts Directory Guide](scripts.md).
- Новое аналитическое событие или privacy-ограничение: обновить [Product Analytics](../product/analytics.md).
- Исторически значимое архитектурное решение: создать ADR в `docs/adr/` со статусом `proposed`; статус `accepted` или `rejected` ставить только после явного решения пользователя.
