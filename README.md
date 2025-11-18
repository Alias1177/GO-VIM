# Мой AstroNvim конфиг

Этот репозиторий содержит персональную настройку AstroNvim 5 с упором на Go и YAML. Основные плагины и улучшения включают Catppuccin, Noice, Trouble, Copilot, а также расширенную поддержку Go (go.nvim, nvim-dap-go) и YAML (yaml-companion).

## Основные фичи

### Автосохранение
- Автоматическое сохранение при переключении между режимами (insert ↔ normal) для изменённых буферов.
- Специальная обработка Go файлов: автоматическая организация импортов и сохранение при выходе из режима вставки (если активен `gopls`).

### Терминал
- Встроенный нижний терминал ToggleTerm с высотой 15 строк.
- Переключение по `<C-,>` в normal и terminal режимах.
- Автоматическая настройка терминальных буферов (скрыты из списка, без swap-файлов).

### LSP и подсказки
- Стабильные LSP inlay hints с единым переключателем (`<leader>uh`) и совместимостью разных API Neovim.
- По умолчанию inlay hints отключены, включаются вручную.
- Полная поддержка gopls с gofumpt, автоимпортом неимпортированных пакетов, анализом кода.
- Format on save для Go файлов.
- Расширенные codelenses для Go (generate, test, gc_details, tidy, upgrade_dependency, vendor).

### GitHub Copilot
- Автоматические предложения с debounce 75ms.
- Удобные биндинги для навигации и принятия предложений.
- Панель Copilot для просмотра альтернативных вариантов.
- Отключён для markdown и help файлов.

### Отладка (DAP)
- Полная интеграция nvim-dap с UI (nvim-dap-ui) и виртуальным текстом.
- Специальная настройка для Go с 4 конфигурациями:
  - Отладка текущего пакета
  - Отладка корня workspace
  - Отладка текущего теста
  - Отладка всех тестов пакета
- Автоматическое открытие/закрытие DAP UI при начале/завершении отладки.

### UI и тема
- Catppuccin Macchiato с интеграциями для всех основных плагинов.
- Noice.nvim для улучшенного UI сообщений и командной строки.
- Trouble для удобной работы с диагностикой и todo-комментариями.
- Indent-blankline с подсветкой текущего scope.

### Управление проектами
- Project.nvim с автоматическим определением проектов по `.git`, `go.mod`, `go.work`, `package.json`, `pyproject.toml`.
- Telescope интеграция для быстрого переключения между проектами.

## Пользовательские хоткеи

### Навигация и буферы
| Комбинация | Описание |
| --- | --- |
| `<S-h>` | Предыдущий буфер |
| `<S-l>` | Следующий буфер |

### Общие сочетания
| Комбинация | Описание |
| --- | --- |
| `<C-c>` (вставка) | Ведёт себя как `<Esc>`, чтобы срабатывали автокоманды выхода из режима вставки |
| `<C-,>` | Переключить нижний терминал ToggleTerm (работает в normal и terminal режимах) |

### UI и интерфейс
| Комбинация | Описание |
| --- | --- |
| `<leader>uh` | Вкл/выкл LSP inlay hints в текущем буфере |
| `<leader>xd` | Панель Diagnostics (Trouble) |
| `<leader>xl` | Локальный список (Trouble) |
| `<leader>xt` | Todo List (Trouble) |
| `<leader>sm` | История сообщений (Noice) |
| `<leader>sn` | Скрыть сообщения (Noice) |

### Проекты
| Комбинация | Описание |
| --- | --- |
| `<leader>fp` | Смена проекта через Telescope Projects |

### GitHub Copilot
| Комбинация | Описание |
| --- | --- |
| `<M-l>` (вставка) | Принять предложение Copilot |
| `<M-]>` (вставка) | Следующее предложение Copilot |
| `<M-[>` (вставка) | Предыдущее предложение Copilot |
| `<C-]>` (вставка) | Отклонить предложение Copilot |
| `<leader>ua` | Переключить автоподсказки GitHub Copilot |
| `<leader>sp` | Открыть Copilot Panel |

### Отладка (DAP)
| Комбинация | Описание |
| --- | --- |
| `<F5>` | Continue (запуск/продолжение отладки) |
| `<F10>` | Step Over (шаг через функцию) |
| `<F11>` | Step Into (шаг внутрь функции) |
| `<F12>` | Step Out (шаг из функции) |
| `<leader>b` | Toggle Breakpoint (переключить точку останова) |
| `<leader>du` | Toggle DAP UI (переключить интерфейс отладчика) |

### Горячие клавиши для Go файлов
Эти сочетания активируются только для буферов Go (`go`, `gomod`, `gowork`).

| Комбинация | Команда |
| --- | --- |
| `<C-l>` | `GoImplements` — показать реализации интерфейса |
| `<leader>ct` | `GoTest` — тестировать пакет |
| `<leader>cT` | `GoTestFunc` — тестировать текущую функцию |
| `<leader>cr` | `GoRun` — запустить модуль |
| `<leader>cb` | `GoBuild` — собрать пакет |
| `<leader>ci` | `GoIfErr` — вставить сниппет if err |
| `<leader>cA` | `GoAddTag` — добавить теги к структурам (запросит тип тега) |
| `<leader>cR` | `GoRmTag` — удалить теги у структур (запросит тип тега) |

## Поддержка YAML
- Интеграция `yaml-companion` для работы с YAML схемами.
- LSP `yamlls` настроен с отключённой валидацией по умолчанию и пустым schemaStore.
- Kubernetes схемы отключены (см. `lua/plugins/astrolsp.lua:98`).
- Расширение Telescope для выбора YAML схем: `:Telescope yaml_schema`.
- Поддержка типов файлов: `yaml`, `yml`, `yaml.docker-compose`.

## Структура конфигурации

```
~/.config/nvim/
├── init.lua                          # Точка входа, загрузка lazy.nvim, основные биндинги
├── lua/
│   ├── lazy_setup.lua                # Настройка lazy.nvim
│   ├── community.lua                 # Импорт плагинов из AstroCommunity
│   ├── polish.lua                    # Основная кастомизация (auto-save, Go, терминал)
│   ├── user/
│   │   └── polish.lua                # Дополнительные биндинги (inlay hints, Trouble, Noice, Copilot)
│   └── plugins/
│       ├── astrocore.lua             # Конфигурация AstroCore (отключён)
│       ├── astrolsp.lua              # Настройка LSP (gopls, yamlls)
│       ├── astroui.lua               # Настройка UI
│       ├── treesitter.lua            # Настройка Treesitter
│       ├── mason.lua                 # Настройка Mason
│       ├── neo-tree.lua              # Настройка Neo-tree
│       ├── none-ls.lua               # Настройка none-ls
│       ├── dap.lua                   # Настройка отладчика и биндингов
│       └── user.lua                  # Кастомные плагины (Catppuccin, Noice, Trouble, Copilot, Go, YAML)
└── README.md
```

### Важные файлы для кастомизации
- `init.lua:28-30` - Глобальные биндинги для буферов и Go
- `lua/polish.lua` - Автосохранение, Go-специфичные биндинги, терминал
- `lua/user/polish.lua` - UI биндинги (Trouble, Noice, Copilot, Projects)
- `lua/plugins/user.lua` - Настройка основных плагинов
- `lua/plugins/astrolsp.lua` - Конфигурация LSP серверов
- `lua/plugins/dap.lua` - Отладка и связанные биндинги

## Используемые плагины

### Из AstroCommunity
- `copilot-lua-cmp` - GitHub Copilot с интеграцией в nvim-cmp
- `noice-nvim` - Современный UI для сообщений и командной строки
- `trouble-nvim` - Панель диагностики и списков
- `todo-comments-nvim` - Подсветка TODO комментариев
- `project-nvim` - Управление проектами
- `indent-blankline-nvim` - Визуализация отступов
- `catppuccin` - Цветовая схема
- `pack.yaml` - Базовая поддержка YAML

### Кастомные плагины
- `ray-x/go.nvim` - Расширенная поддержка Go
- `leoluz/nvim-dap-go` - Отладка Go программ
- `someone-stole-my-name/yaml-companion.nvim` - Работа с YAML схемами
- `mfussenegger/nvim-dap` - Debug Adapter Protocol
- `rcarriga/nvim-dap-ui` - UI для отладчика
- `theHamsta/nvim-dap-virtual-text` - Виртуальный текст в отладчике

## Требования
- Neovim >= 0.9.0 (рекомендуется >= 0.10.0 для полной поддержки inlay hints)
- Git
- Nerd Font (для иконок)
- ripgrep (для поиска)
- Node.js (для некоторых LSP серверов)
- Go >= 1.21 (для Go разработки)
- gopls (устанавливается через Mason)

## Установка

### Шаг 1: Бэкап текущей конфигурации
```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### Шаг 2: Клонирование репозитория
```bash
git clone https://github.com/<user>/<repo> ~/.config/nvim
```

### Шаг 3: Первый запуск
```bash
nvim
```
При первом запуске:
1. Lazy.nvim автоматически установит все плагины
2. Mason установит необходимые LSP серверы
3. Treesitter установит парсеры для поддерживаемых языков

### Шаг 4: Установка LSP серверов (опционально)
После запуска можно вручную установить дополнительные серверы:
```vim
:Mason
```

## Полезные команды

### Управление плагинами
- `:Lazy` - Открыть менеджер плагинов
- `:Lazy sync` - Синхронизировать плагины (update + clean + install)
- `:Lazy update` - Обновить плагины
- `:Lazy clean` - Удалить неиспользуемые плагины

### LSP и Mason
- `:Mason` - Открыть Mason для управления LSP/DAP/linters/formatters
- `:LspInfo` - Информация о подключённых LSP серверах
- `:LspRestart` - Перезапустить LSP серверы

### Go разработка
- `:GoInstallBinaries` - Установить/обновить Go инструменты
- `:GoUpdateBinaries` - Обновить все Go инструменты
- `:GoModTidy` - Выполнить go mod tidy

### YAML
- `:Telescope yaml_schema` - Выбрать YAML схему для текущего файла

### Отладка
- `:DapContinue` - Запустить/продолжить отладку
- `:DapToggleBreakpoint` - Переключить точку останова
- `:DapStepOver` - Шаг через
- `:DapStepInto` - Шаг внутрь
- `:DapStepOut` - Шаг наружу

### AstroNvim
- `:AstroUpdate` - Обновить AstroNvim (если используется)
- `:AstroChangelog` - Показать changelog

## Troubleshooting

### Проблемы с LSP
Если LSP не работает:
1. Проверьте установку серверов: `:Mason`
2. Проверьте логи: `:LspLog`
3. Перезапустите LSP: `:LspRestart`

### Проблемы с Go
Если go.nvim не работает:
1. Установите инструменты: `:GoInstallBinaries`
2. Проверьте, что gopls установлен: `which gopls`
3. Проверьте, что Go в PATH: `which go`

### Проблемы с Copilot
Если Copilot не работает:
1. Проверьте авторизацию: `:Copilot auth`
2. Проверьте статус: `:Copilot status`

## Лицензия
MIT
