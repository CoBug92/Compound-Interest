# SwiftLint Rules Guide

Этот документ описывает текущую политику SwiftLint в проекте и предназначен для разработчиков и AI-агентов, которые будут менять код приложения. Каноническая машинная конфигурация находится в `scripts/swiftlint/.swiftlint.yml`; если этот документ с ней расходится, нужно исправить одно из двух явно, а не молча.

Структура Swift-файлов и порядок `MARK`-секций описаны отдельно в [Project Guidelines](project-guidelines.md). SwiftLint проверяет корректность написания `MARK` и пустую строку после него, но не проверяет смысл текста после `MARK`.

## Общая политика

Проект использует whitelist-подход через `only_rules` в `scripts/swiftlint/.swiftlint.yml`: активны только явно перечисленные правила. Если нужно добавить новое правило, его надо добавить в `only_rules` и при необходимости описать отдельную конфигурацию ниже.

Правила делятся на два уровня:

- `error` — нарушение считается блокирующим и должно исправляться сразу.
- `warning` — нарушение желательно исправлять, но оно не должно блокировать сборку или крупные миграции.

## Обязательные style/error правила

Эти правила задают базовый формат Swift-кода и должны соблюдаться при любых изменениях:

- `closing_brace`, `opening_brace` — корректные пробелы вокруг фигурных скобок.
- `closure_parameter_position`, `closure_spacing` — единый стиль closure-блоков.
- `colon`, `comma`, `operator_usage_whitespace`, `return_arrow_whitespace` — стандартные пробелы вокруг синтаксиса.
- `control_statement`, `statement_position`, `mark` — читаемый стиль control flow и `// MARK:`.
- `trailing_newline`, `trailing_semicolon`, `leading_whitespace`, `vertical_whitespace` — базовая чистота строк и пустых строк.
- `empty_parameters`, `empty_parentheses_with_trailing_closure`, `void_return` — единый стиль `Void`, trailing closures и function signatures.
- `syntactic_sugar` — использовать `[Type]`, `Type?`, `Type!` вместо длинных generic-форм.

## Безопасность и correctness

Эти правила важны не только для стиля, но и для предотвращения ошибок:

- `force_cast`, `force_try`, `force_unwrapping` — запрещают небезопасные `as!`, `try!`, `!`.
- `overridden_super_call`, `prohibited_super_call` — контролируют обязательные и запрещённые вызовы `super`.
- `unused_closure_parameter`, `unused_enumerated`, `unused_optional_binding` — убирают ложные или неиспользуемые значения.
- `first_where`, `empty_count`, `contains_over_filter_is_empty`, `contains_over_filter_count`, `contains_over_first_not_nil` — предотвращают неэффективные операции с коллекциями.
- `identical_operands` — ловит сравнения вроде `value == value`.
- `fatal_error_message` — требует осмысленное сообщение в `fatalError`.

## Readability и maintainability

Эти правила поддерживают читаемость и единообразие:

- `file_length` — файл не должен быть слишком большим; текущий error-limit: `400` строк.
- `line_length` — warning после `140`, error после `150` символов.
- `type_name` — типы должны иметь читаемые имена; короткие имена разрешены, максимумы: warning `60`, error `70`.
- `sorted_imports`, `duplicate_imports`, `unused_import` — imports должны быть отсортированы, уникальны и реально нужны.
- `trailing_whitespace`, `vertical_whitespace_closing_braces` — сейчас warning, чтобы whitespace-очистка не превращалась в шумный массовый diff без отдельной задачи.
- `todo` — оставлен как warning. TODO в этом проекте могут обозначать согласованную последующую работу, поэтому не удаляйте их автоматически.

## Deprecated и миграционные замечания

- Не использовать `redundant_optional_initialization`: в SwiftLint `0.65.0` правило переименовано в `implicit_optional_initialization`.
- `implicit_optional_initialization` не включаем: оно даёт шум на optionals с осмысленными non-nil default values, например `Decimal? = 100000`.
- Если проект будет массово отформатирован, можно рассмотреть повышение новых whitespace/import rules с `warning` до `error`.

## Custom rules

В проекте остаются custom rules, потому что не все требования покрываются встроенными правилами SwiftLint:

- `guard_space_rule` — для многострочного `guard` с коротким `else` ожидается компактный `else { return }`.
- `blank_line_after_mark_rule` — после `// MARK: - ...` должна быть одна пустая строка.
- `duplicated_spaces_custom_rule` — запрещает несколько пробелов между токенами внутри строки. Полного встроенного аналога в SwiftLint нет.
- `access_control_custom_rule` — access modifier должен идти перед другими модификаторами, например `public override`, а не `override public`.
- `space_after_super_init_custom_rule` — после `super.init()` должен быть визуальный отступ, если дальше идёт код.

`space_after_colon_custom_rule` удалён, потому что встроенное правило `colon` уже корректно покрывает пробелы после двоеточия.

## Как работать с правилами

Перед сдачей изменений запускайте:

```sh
scripts/swiftlint/swiftlint.sh
```

Если правило выдаёт warning, лучше исправить код, если это не создаёт шумную механическую правку. Если warning массовый и не связан с текущей задачей, не исправляйте весь проект без отдельного решения.

Если правило выдаёт error, исправьте нарушение в рамках текущей задачи. Не отключайте правило локально без веской причины.

Для проверки доступности конкретного правила используйте:

```sh
swiftlint rules <rule_id>
```

## Рекомендации для AI-агентов

- Не удаляйте `todo` только ради чистого lint: сначала проверьте, не фиксирует ли комментарий реальную незавершённую работу или техническое ограничение.
- Не ослабляйте `force_unwrapping`, `force_cast`, `force_try` без явного запроса.
- Не возвращайте CocoaPods/Pods в `excluded`: проект мигрирован на Swift Package Manager.
- Не запускайте auto-correct на весь проект без отдельного разрешения: это создаст большой шумный diff.
- При добавлении нового правила сначала ставьте `warning`, прогоняйте lint и оценивайте количество существующих нарушений.
