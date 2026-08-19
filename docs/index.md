# Документация Compound Interest

Этот раздел собирает актуальную проектную документацию iOS-приложения `Compound Interest`. Корневой [README](../README.md) остаётся короткой входной точкой, а подробные материалы живут в `docs/`.

## Быстрый маршрут

- Новому разработчику: [обзор README](../README.md), затем [структура проекта](tech/project-structure.md), [архитектура](tech/architecture.md) и [скрипты/CI/deploy](tech/scripts.md).
- Разработчику UI или flow: [пользовательские сценарии](product/user-scenarios.md), [архитектура](tech/architecture.md), [project guidelines](engineering/project-guidelines.md).
- Разработчику аналитики или privacy: [аналитика](product/analytics.md).
- Разработчику build/release-инфраструктуры: [скрипты/CI/deploy](tech/scripts.md), [SwiftLint](engineering/swiftlint-rules.md), [Swift style](engineering/swift-style.md).

## Карта документов

### Обзор и продукт

- [README](../README.md) — назначение приложения, быстрый старт, основные команды и ссылки.
- [Пользовательские сценарии](product/user-scenarios.md) — подтверждённые сценарии расчёта, истории, повторного применения и PDF-экспорта.
- [Product Analytics](product/analytics.md) — контракт аналитических событий и privacy-ограничения.

### Техническая документация

- [Архитектура](tech/architecture.md) — слои приложения, зависимости, поток данных и ограничения.
- [Структура проекта](tech/project-structure.md) — назначение каталогов и правила размещения новых файлов.
- [Scripts Directory Guide](tech/scripts.md) — bootstrap, генерация, SwiftGen, XcodeGen, SwiftLint, Fastlane, CI и deploy.
- [Технические решения и ограничения](tech/technical-decisions.md) — текущие проектные решения, подтверждённые конфигурацией и кодом, без статуса ADR.

### Engineering

- [Project guidelines](engineering/project-guidelines.md) — архитектурные и SwiftUI-правила проекта.
- [Swift Style](engineering/swift-style.md) — стиль Swift-кода.
- [SwiftLint Rules](engineering/swiftlint-rules.md) — текущая политика SwiftLint.

## Что не описано

- Внешний SDK/API отсутствует в найденной структуре проекта, поэтому каталог `docs/integration/` не создавался.
- ADR отсутствуют. Если появится необходимость зафиксировать причину архитектурного решения, стоит создать отдельный документ в `docs/adr/` со статусом `proposed` до явного принятия.
