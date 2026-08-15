# Compound Interest

iOS-приложение для расчёта сложного процента. Пользователь задаёт стартовый капитал, регулярные пополнения, срок инвестирования и годовую ставку, а приложение показывает ключевые показатели, график роста капитала и помесячную детализацию.

## Возможности

- Расчёт итогового капитала, внесённой суммы, заработанных процентов и доходности.
- Регулярные пополнения: без пополнений, ежемесячно, ежеквартально или ежегодно.
- Срок инвестирования в годах или месяцах.
- Интерактивный график капитала по месяцам.
- Локальная история расчётов с повторным применением и удалением записей.
- Экспорт помесячной детализации капитала в PDF.
- Локализация на русском и английском.

## Технологии

- SwiftUI
- Charts
- SwiftData для локального хранения истории расчётов
- Firebase Analytics через `FirebaseAnalyticsCore`
- XcodeGen для генерации `.xcodeproj`
- SwiftGen для type-safe доступа к локализациям
- SwiftLint для проверки стиля
- Fastlane для TestFlight deploy

## Структура проекта

```text
Compound Interest/
├── App/                 # Lifecycle и app entry point
├── Core/                # Переносимые сервисы
├── Flows/               # View layer и feature-specific UI
├── Infrastructure/      # Persistence и доступ к данным
├── Model/               # Database, Domain и DTO-модели
├── Common/              # Универсальные reusable-компоненты проекта
└── Resources/           # Assets, localization, Info.plist

UnitTests/                # Тесты, зеркалирующие production-слои
scripts/                 # Генерация, lint и release automation
docs/                    # Проектные правила и документация
```

## Быстрый старт

1. Установите Xcode и command line tools.
2. Проверьте настройки в `scripts/.env`. Этот файл хранится в репозитории и является единым источником не-секретных настроек проекта.

```sh
cat scripts/.env
```

3. Запустите bootstrap: он установит зависимости через Homebrew/Bundler, сгенерирует ресурсы и Xcode-проект, а затем откроет проект в Xcode:

```sh
scripts/bootstrap.sh
```

Подробности по скриптам, CI и deploy находятся в `docs/scripts.md`.

## Разработка

Запуск SwiftGen и XcodeGen:

```sh
scripts/generate.sh
```

Запуск SwiftLint:

```sh
scripts/swiftlint/swiftlint.sh
```

Точечная проверка изменённого файла:

```sh
swiftlint lint --config scripts/swiftlint/.swiftlint.yml --no-cache "Compound Interest/Flows/Main/Views/MainParameterInputView.swift"
```

Проверка сборки без подписи:

```sh
xcodebuild \
  -project "Compound Interest.xcodeproj" \
  -scheme "CompoundInterest" \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Запуск unit-тестов тем же маршрутом, который использует CI:

```sh
cd scripts/fastlane
bundle exec fastlane ios test
```

Если в sandbox/CI нет доступного Simulator runtime, `xcodebuild` может падать на CoreSimulator tooling до запуска приложения. В таком случае отдельно проверяйте SwiftLint и локальную сборку в Xcode.

## CI и Deploy

В репозитории есть два GitHub Actions workflow:

- `.github/workflows/verify.yml` — проверка pull request в `master`.
- `.github/workflows/testflight-deploy.yml` — deploy в TestFlight при `push` в `master`.

Операционные детали по CI, runner setup, secrets, Fastlane и Match находятся в `docs/scripts.md`.

## Гайдлайны

Перед изменениями полезно прочитать:

- `docs/project-guidelines.md` — архитектурные и SwiftUI-правила проекта.
- `docs/swift-style.md` — стиль Swift-кода.
- `docs/swiftlint-rules.md` — текущая политика SwiftLint.
- `docs/scripts.md` — устройство скриптов генерации, lint и deploy.
- `docs/analytics.md` — контракт событий, privacy-ограничения и настройка Firebase.

Ключевые правила:

- Используйте сгенерированные symbols для ассетов и локализаций.
- Не добавляйте `MARK`-секции механически: они должны помогать навигации.
- Длинные списки внутри `ScrollView` делайте ленивыми через `LazyVStack`.
- Runtime warnings сначала классифицируйте: системный шум Xcode/Simulator/UIKit не стоит маскировать сложными workaround-ами в app code.
- UI controls с визуальным суффиксом должны иметь корректную hit area и не уезжать за экран на длинных значениях.

## Deploy

Fastlane находится в `scripts/fastlane`. Локальный запуск lane:

```sh
bundle exec fastlane ios deploy
```

Полное описание deploy-процесса, секретов и signing-настроек находится в `docs/scripts.md`.
