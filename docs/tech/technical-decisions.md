# Технические решения и ограничения

Документ фиксирует текущие технические решения, подтверждённые кодом и конфигурацией. Это не ADR: здесь не указаны автор, дата принятия и рассмотренные альтернативы. Если нужно зафиксировать причину нового решения, создайте отдельный ADR со статусом `proposed`.

## Подтверждённые решения

### SwiftUI и MVVM для flow

Факты:

- `RootView`, `MainView`, `HistoryView` и дочерние компоненты реализованы на SwiftUI.
- `MainViewModel` и `HistoryViewModel` владеют состоянием и пользовательскими действиями соответствующих flow.
- [Project Guidelines](../engineering/project-guidelines.md) явно требуют MVVM для flow и dumb presentation views.

Ограничение: в проекте нет отдельного coordinator-слоя; навигация истории реализована через `NavigationStack` и `NavigationLink`.

### Локальная история через SwiftData

Факты:

- `HistoryStore` создаёт `ModelContainer` для `HistorySchemaV1`.
- Хранилище размещается в `Application Support/History/History.store`.
- `cloudKitDatabase` установлен в `.none`.
- Для доступа UI к истории используется протокол `HistoryRepository`.

Ограничение: синхронизация между устройствами не реализована в найденной конфигурации.

### Firebase Analytics без IDFA-зависимого продукта

Факты:

- XcodeGen подключает Swift Package product `FirebaseAnalyticsCore`.
- `MainApp` создаёт `FirebaseAnalyticsClient`.
- `Info.plist` свойства в XcodeGen отключают automatic screen reporting, IDFV collection и ad personalization signals.
- Разрешённые события описаны в [Product Analytics](../product/analytics.md).

Ограничение: интеграция считается ошибочной, если отсутствует или неверно настроен `GoogleService-Info.plist`; это прямо зафиксировано в документе аналитики.

### XcodeGen как источник Xcode-проекта

Факты:

- README и [Scripts Directory Guide](scripts.md) описывают генерацию `.xcodeproj` через `scripts/generate.sh`.
- XcodeGen spec находится в `scripts/xcodegen`.
- Build phases generated project запускают SwiftGen и SwiftLint.

Ограничение: ручные изменения в `.xcodeproj` могут быть перезаписаны генерацией, если не отражены в XcodeGen-конфигурации.

### SwiftGen и generated resources

Факты:

- `Application.yml` добавляет pre-build script `./scripts/swiftgen/swiftgen.sh`.
- `Resources/Generated/Localizations.swift` указан как output SwiftGen.
- [Project Guidelines](../engineering/project-guidelines.md) запрещает ручное редактирование `Resources/Generated`.

Ограничение: при изменении локализаций или конфигурации ресурсов нужно запускать генерацию, иначе Xcode-проект и generated-файлы могут расходиться.

### Portrait-only iPhone app

Факты:

- `Application.yml` задаёт `TARGETED_DEVICE_FAMILY: 1`.
- `Application.yml` задаёт `UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait`.
- `SUPPORTS_MACCATALYST` и `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD` установлены в `NO`.

Ограничение: iPad, Mac Catalyst и landscape-сценарии не подтверждены текущей конфигурацией.

### Fastlane для TestFlight deploy

Факты:

- README и [Scripts Directory Guide](scripts.md) указывают Fastlane в `scripts/fastlane`.
- Deploy lane разрешён только из `master`.
- После успешного deploy workflow пушит только release tag и не коммитит изменения обратно в `master`.

Ограничение: фактический доступ к App Store Connect, Match и секретам GitHub Actions не проверялся в рамках документационного аудита.

## Открытые вопросы

- Почему выбран `IPHONEOS_DEPLOYMENT_TARGET: 26.0`, в репозитории не объяснено.
- Почему выбран SwiftData вместо другого persistence-подхода, ADR не найден.
- Почему выбран Firebase Analytics и текущий набор событий, кроме privacy-ограничений в [Product Analytics](../product/analytics.md), не объяснено.
- Требования к точности финансовой модели, округлению и отображению валюты не найдены.
- Политика миграций SwiftData пока не описывает реальные stages: `HistoryMigrationPlan.stages` пуст.

## Когда нужен ADR

Создавайте ADR, если меняется одно из решений выше или появляется новое решение с долгосрочными последствиями:

- persistence-стек;
- аналитическая платформа и privacy-контракт;
- минимальная версия iOS;
- архитектурный слой или граница flow;
- release/deploy-процесс;
- финансовая модель расчёта.

До явного решения пользователя новый ADR должен иметь статус `proposed`.
