# sysgate

> **One command. Full server audit. Fix commands included.**  
> Security score, bilingual output, zero dependencies.

![Version](https://img.shields.io/badge/version-1.0.0-green?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Debian%20%7C%20Ubuntu-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Lang](https://img.shields.io/badge/lang-EN%20%2F%20RU-orange?style=flat-square)

---

## What it does

sysgate runs a security and health audit on your server in seconds. It checks SSH configuration, firewall, open ports, services, updates, and more — then tells you exactly what to fix and how.

Every `[FAIL]` and `[WARN]` comes with a ready-to-run command. No manual research required.

```
  [ SSH ]
  [PASS] SSH is running
  [WARN] SSH port: 22 - consider changing to non-default
  [FAIL] SSH root login: Root login permitted - critical vulnerability
         Risk: Full server access directly via root
         Fix:  sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd
  [WARN] SSH password auth: Password auth enabled - key-only recommended
         Risk: Vulnerable to brute-force attacks
         Fix:  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd

  ==========================================
  PASS: 4   WARN: 6   FAIL: 1   INFO: 12
  Security score: 55/100
  Critical issues: 1 - fix these first
  ==========================================
```

---

## Quick Start

```bash
# Download and run
curl -sO https://raw.githubusercontent.com/ceo714/sysgate/main/linux/sysgate.sh
chmod +x sysgate.sh
sudo ./sysgate.sh
```

No installation. No dependencies. One file.

---

## What gets checked

| Section | Checks |
|---------|--------|
| **System** | OS, kernel version, hostname, uptime, virtualization |
| **Resources** | CPU cores, RAM usage, disk usage, swap |
| **Network** | Open ports, listening services |
| **SSH** | Running status, port, root login, password auth |
| **Firewall** | UFW status, iptables rules |
| **Security** | Fail2ban, root password, world-writable files, sudoers |
| **Updates** | Available packages, unattended-upgrades |
| **Logins** | Last 5 login entries |

---

## Output levels

| Level | Meaning |
|-------|---------|
| `[PASS]` | All good |
| `[WARN]` | Recommended to fix — includes fix command |
| `[FAIL]` | Fix immediately — includes risk description and fix command |
| `[INFO]` | Informational — no action needed |

---

## Options

```bash
sudo ./sysgate.sh [options]

--lang ru|en        output language (default: autodetect from $LANG)
--section NAME      run single section only
--output FILE       save report to custom path
--no-save           do not save report to file
--help              show help
```

### Run a single section

```bash
sudo ./sysgate.sh --section ssh
sudo ./sysgate.sh --section firewall
sudo ./sysgate.sh --section updates
```

Available sections: `system`, `resources`, `network`, `ssh`, `firewall`, `security`, `updates`, `logins`

### Save report to file

```bash
# Default — saves to sysgate-report-YYYY-MM-DD.txt automatically
sudo ./sysgate.sh

# Custom path
sudo ./sysgate.sh --output /root/audit.txt

# No file
sudo ./sysgate.sh --no-save
```

### Read saved report

```bash
cat sysgate-report-2026-03-22.txt
```

---

## Language support

sysgate auto-detects language from your system's `$LANG` variable.

```bash
sudo ./sysgate.sh --lang ru    # Russian
sudo ./sysgate.sh --lang en    # English
```

Language files are loaded from `lang/ru.sh` and `lang/en.sh` if present.  
If lang files are missing, English fallback is built into the script — sysgate works standalone as a single file.

---

## Compatibility

| OS | Status |
|----|--------|
| Debian 11 (Bullseye) | ✅ |
| Debian 12 (Bookworm) | ✅ Tested |
| Ubuntu 20.04 LTS | ✅ |
| Ubuntu 22.04 LTS | ✅ |
| Ubuntu 24.04 LTS | ✅ |
| Other Debian-based | ✅ likely compatible |
| CentOS / RHEL | ⚠️ partial (no apt checks) |
| Windows Server | planned v1.1.0 |

---

## Repository structure

```
sysgate/
├── linux/
│   └── sysgate.sh          # main audit script — works standalone
├── lang/
│   ├── ru.sh               # Russian strings
│   └── en.sh               # English strings
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## Security score

sysgate calculates a score from 0 to 100 based on audit results:

- each `[FAIL]` deducts 15 points
- each `[WARN]` deducts 5 points
- score is clamped at 0 minimum

| Score | Status |
|-------|--------|
| 90–100 | Good |
| 70–89 | Acceptable |
| 50–69 | Needs attention |
| < 50 | Critical — fix immediately |

---

---

## RU — Русская документация

### Что такое sysgate

sysgate — инструмент для аудита безопасности и состояния Linux-сервера. Запускается одной командой, проверяет SSH, файрвол, открытые порты, обновления и многое другое. По каждой найденной проблеме — готовая команда для исправления.

Подходит для любого уровня: от первого VPS до боевого сервера.

### Быстрый старт

```bash
curl -sO https://raw.githubusercontent.com/ceo714/sysgate/main/linux/sysgate.sh
chmod +x sysgate.sh
sudo ./sysgate.sh --lang ru
```

### Использование

```bash
sudo ./sysgate.sh --lang ru              # полный аудит на русском
sudo ./sysgate.sh --section ssh          # только SSH
sudo ./sysgate.sh --section firewall     # только брандмауэр
sudo ./sysgate.sh --no-save              # без сохранения отчёта
sudo ./sysgate.sh --help                 # справка
```

### Что проверяется

**Система** — версия ОС, ядро, имя хоста, аптайм, виртуализация.

**Ресурсы** — ядра CPU, использование RAM и диска, swap.

**Сеть** — открытые порты, слушающие сервисы.

**SSH** — статус, порт, вход root, парольная аутентификация.

**Брандмауэр** — UFW, iptables.

**Безопасность** — Fail2ban, пароль root, файлы с мировой записью, sudoers.

**Обновления** — доступные пакеты, автообновления.

**Входы** — последние 5 сессий.

### Уровни вывода

`[PASS]` — всё хорошо. `[WARN]` — рекомендуется исправить. `[FAIL]` — исправить немедленно, команда прилагается. `[INFO]` — информация без оценки.

### Оценка безопасности

По итогам аудита выводится оценка от 0 до 100. Каждый `[FAIL]` снимает 15 очков, каждый `[WARN]` — 5. Оценка ниже 50 означает критические проблемы.

### Совместимость

Debian 11/12, Ubuntu 20.04/22.04/24.04 и другие Debian-based дистрибутивы. Windows Server — в планах v1.1.0.

---

## Author

**ceo714** — [GitHub](https://github.com/ceo714)

Related projects:
- [win-baseline](https://github.com/ceo714/win-baseline) — Windows 10/11 performance baseline
- [bye-tcp-internet](https://github.com/ceo714/bye-tcp-internet) — TCP/IP network stack tuning

## License

MIT
