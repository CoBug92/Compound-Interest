# scripts Directory Guide

Документ описывает назначение папки `scripts`, entrypoint-скрипты, общий `scripts/.env` и release-инфраструктуру проекта. Это канонический документ по скриптам, CI и deploy.

## Общая идея

`scripts` содержит генерацию проекта, SwiftGen, SwiftLint, XcodeGen и Fastlane. Единый источник правды для не-секретных настроек проекта — tracked файл `scripts/.env`. Shell-скрипты, XcodeGen, Fastlane и GitHub Actions читают одни и те же значения из этого файла; секреты deploy остаются только в GitHub Secrets.

## Структура

```text
scripts/
  .env
  bootstrap.sh
  generate.sh
  fastlane/
  swiftgen/
  swiftlint/
  xcodegen/
```

## Environment

`scripts/.env` используется одинаково из shell-скриптов, XcodeGen, Fastlane и GitHub Actions. Для CI схема берётся из `TARGET_NAME`. Simulator destination можно переопределить через `CI_XCODE_DESTINATION`, а destination для unsigned build — через `CI_BUILD_DESTINATION`. По умолчанию Fastlane сам находит первый доступный iPhone simulator для тестов, а для unsigned build использует `generic/platform=iOS Simulator`.

```sh
PROJECT_NAME="Compound Interest"
APP_DISPLAY_NAME="Сложный процент"
TARGET_NAME="CompoundInterest"
TEAM_ID="Q9WXSNT6UT"
BUNDLE_ID="ru.kostyuchenko.compoundInterest"
```

Не храните в `scripts/.env` секреты App Store Connect и `MATCH_PASSWORD`.

## Entrypoints

### `scripts/bootstrap.sh`

Ставит CLI-инструменты из `Brewfile`, при наличии Bundler ставит Ruby-зависимости, проверяет наличие `scripts/.env`, просит интерактивно подтвердить, что файл уже заполнен, затем запускает `scripts/generate.sh` и открывает `.xcodeproj`.

### `scripts/generate.sh`

Загружает `scripts/.env`, при необходимости переименовывает legacy-каталог `AppName` в `${PROJECT_NAME}`, создаёт `${PROJECT_NAME}/Resources/Generated`, затем запускает SwiftGen и XcodeGen.

## XcodeGen

Файлы XcodeGen находятся в `scripts/xcodegen`.

- `project.yml` — верхнеуровневый spec
- `Application.yml` — target, settings, build phases и test targets
- `xcodegen.sh` — wrapper вокруг `xcodegen`

Build phases внутри generated project указывают на `./scripts/swiftgen/swiftgen.sh` и `./scripts/swiftlint/swiftlint.sh`.

## SwiftLint

Файлы SwiftLint находятся в `scripts/swiftlint`.

- `.swiftlint.yml` — whitelist-конфигурация
- `swiftlint.sh` — wrapper для локального запуска и CI

Wrapper загружает `scripts/.env`, вычисляет lint path из `PROJECT_NAME` и завершает процесс с ошибкой, если SwiftLint нашёл нарушения или если tool не установлен. Это важно для `verify` workflow.

## Fastlane

Fastlane находится в `scripts/fastlane`.

- `Appfile` читает `BUNDLE_ID` из `scripts/.env`
- `Matchfile` хранит `git_url`, `git_branch` и остальные match-специфичные настройки, а `TEAM_ID` и `BUNDLE_ID` читает из `scripts/.env`
- `Fastfile` содержит stage-lanes `generate`, `lint`, `test`, `build`, `deploy` и alias `deploy_to_tf`
- `fastlane/README.md` автогенерируется fastlane и не является источником правды, если расходится с `Fastfile` или этим документом

`test` автоматически выбирает первый доступный iPhone simulator, если явно не задан `CI_XCODE_DESTINATION`.

`build` собирает `Release` без подписи и по умолчанию использует `generic/platform=iOS Simulator`.

`deploy`:
- разрешён только из `master`
- использует встроенный `setup_ci` с уникальным CI keychain на каждый GitHub Actions run
- синхронизирует Match в readonly-режиме
- читает `MARKETING_VERSION` только из `scripts/xcodegen/Application.yml`
- читает build number только из `CURRENT_PROJECT_VERSION` в `scripts/xcodegen/Application.yml`
- вычисляет следующий TestFlight build number
- при закрытом pre-release train автоматически повышает patch у `MARKETING_VERSION`, затем повторяет генерацию и upload в рамках текущего CI run
- обновляет `MARKETING_VERSION` и `CURRENT_PROJECT_VERSION` в `scripts/xcodegen/Application.yml` перед генерацией проекта
- повторно запускает `scripts/generate.sh` перед архивированием
- архивирует Release с `xcargs: DEVELOPMENT_TEAM=<TEAM_ID>` и manual provisioning profile mapping из Match
- загружает архив в TestFlight без дополнительной CI-обвязки вокруг keychain

## CI и deploy

`.github/workflows/verify.yml`:
- запускается на `pull_request` в `master`
- также доступен как reusable workflow через `workflow_call`
- выполняет `generate`, `lint` и `tests` как отдельные job
- job `tests` после успешных `generate` и `lint` запускает и `fastlane ios test`, и `fastlane ios build`

`.github/workflows/testflight-deploy.yml`:
- запускается на `push` в `master`
- выполняет только fastlane lane `deploy_to_tf` на self-hosted runner
- задаёт уникальный `CI_KEYCHAIN_NAME` на каждый run и удаляет этот keychain в `always()` post-step
- reusable `verify` и отдельная job публикации git tag отключены до стабилизации signing

Workflow не коммитят и не пушат изменения обратно в `master`.

## Правила изменения

- Если меняются env-переменные проекта, синхронно обновляйте `scripts/.env`, XcodeGen, Fastlane и workflow.
- Не дублируйте build/lint/test команды в новых местах, если можно расширить существующие wrapper-скрипты или Fastlane lanes.
- После изменения генерации запускайте минимум `scripts/generate.sh`.
