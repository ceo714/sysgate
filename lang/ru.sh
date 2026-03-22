# sysgate — lang/ru.sh
# Russian language strings

# --- Header ---
LANG_TITLE="sysgate — Аудит системы"
LANG_REPORT_SAVED="Отчёт сохранён"
LANG_PRESS_ENTER="Нажмите Enter для продолжения..."

# --- Sections ---
LANG_SECTION_SYSTEM="Система"
LANG_SECTION_NETWORK="Сеть"
LANG_SECTION_SSH="SSH"
LANG_SECTION_FIREWALL="Брандмауэр"
LANG_SECTION_SECURITY="Безопасность"
LANG_SECTION_UPDATES="Обновления"
LANG_SECTION_RESOURCES="Ресурсы"
LANG_SECTION_LOGINS="Последние входы"

# --- Summary ---
LANG_SUMMARY_TITLE="Итог"
LANG_SUMMARY_SCORE="Оценка безопасности"
LANG_SUMMARY_CRITICAL="Критичных проблем"
LANG_SUMMARY_WARN="Предупреждений"
LANG_SUMMARY_FIX_FIRST="— исправь в первую очередь"
LANG_SUMMARY_ALL_GOOD="Всё в порядке. Сервер настроен корректно."

# --- Fix label ---
LANG_FIX="Исправить"
LANG_RISK="Риск"

# --- System checks ---
LANG_OS="ОС"
LANG_KERNEL="Ядро"
LANG_UPTIME="Аптайм"
LANG_HOSTNAME="Имя хоста"
LANG_VIRTUALIZATION="Виртуализация"

# --- Resource checks ---
LANG_CPU_CORES="Ядра CPU"
LANG_RAM_TOTAL="RAM всего"
LANG_RAM_USED="RAM использовано"
LANG_RAM_WARN="RAM использовано более 90%"
LANG_DISK_USAGE="Диск"
LANG_DISK_WARN="Диск заполнен более 85%"
LANG_SWAP_ACTIVE="Swap активен"
LANG_SWAP_MISSING="Swap не настроен — рекомендуется для VPS"

# --- Network checks ---
LANG_OPEN_PORTS="Открытые порты"
LANG_LISTENING_SERVICES="Слушающие сервисы"
LANG_UNEXPECTED_PORTS="Обнаружены неожиданные открытые порты"

# --- SSH checks ---
LANG_SSH_STATUS="SSH статус"
LANG_SSH_RUNNING="SSH запущен"
LANG_SSH_NOT_RUNNING="SSH не запущен"
LANG_SSH_PORT="SSH порт"
LANG_SSH_PORT_DEFAULT="SSH на стандартном порту 22 — рекомендуется сменить"
LANG_SSH_PORT_CUSTOM="SSH на нестандартном порту"
LANG_SSH_ROOT_LOGIN="Root вход по SSH"
LANG_SSH_ROOT_ALLOWED="Root вход разрешён — критическая уязвимость"
LANG_SSH_ROOT_ALLOWED_RISK="Полный доступ к серверу напрямую через root"
LANG_SSH_ROOT_ALLOWED_FIX="sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd"
LANG_SSH_ROOT_DENIED="Root вход запрещён"
LANG_SSH_PASS_AUTH="Парольная аутентификация SSH"
LANG_SSH_PASS_ENABLED="Парольная аутентификация включена — рекомендуются только ключи"
LANG_SSH_PASS_ENABLED_RISK="Уязвимость к brute-force атакам"
LANG_SSH_PASS_ENABLED_FIX="sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd"
LANG_SSH_PASS_DISABLED="Только ключи — парольная аутентификация отключена"
LANG_SSH_CONFIG_NOT_FOUND="Файл конфигурации SSH не найден"

# --- Firewall checks ---
LANG_UFW_STATUS="UFW статус"
LANG_UFW_ACTIVE="UFW активен"
LANG_UFW_INACTIVE="UFW не активен — сервер не защищён"
LANG_UFW_INACTIVE_RISK="Все порты открыты без фильтрации"
LANG_UFW_INACTIVE_FIX="ufw allow ssh && ufw --force enable"
LANG_UFW_NOT_INSTALLED="UFW не установлен"
LANG_UFW_NOT_INSTALLED_FIX="apt install ufw -y && ufw allow ssh && ufw --force enable"
LANG_IPTABLES_RULES="Правила iptables"
LANG_IPTABLES_EMPTY="iptables без правил — нет фильтрации"

# --- Security checks ---
LANG_FAIL2BAN_STATUS="Fail2ban статус"
LANG_FAIL2BAN_ACTIVE="Fail2ban активен"
LANG_FAIL2BAN_INACTIVE="Fail2ban не активен"
LANG_FAIL2BAN_NOT_INSTALLED="Fail2ban не установлен — рекомендуется для защиты от brute-force"
LANG_FAIL2BAN_NOT_INSTALLED_FIX="apt install fail2ban -y && systemctl enable fail2ban && systemctl start fail2ban"
LANG_ROOT_PASS="Пароль root"
LANG_ROOT_PASS_LOCKED="Пароль root заблокирован (только ключи)"
LANG_ROOT_PASS_SET="Пароль root установлен"
LANG_WORLD_WRITABLE="Файлы с мировой записью"
LANG_WORLD_WRITABLE_FOUND="Найдены файлы с правами world-writable в критических директориях"
LANG_WORLD_WRITABLE_RISK="Любой пользователь может изменить эти файлы"
LANG_WORLD_WRITABLE_CLEAN="Критические директории чисты"
LANG_SUDOERS="Проверка sudoers"
LANG_SUDOERS_OK="Файл sudoers корректен"
LANG_SUDOERS_WARN="Обнаружены записи NOPASSWD в sudoers"
LANG_SUDOERS_WARN_RISK="Команды выполняются без пароля"

# --- Updates checks ---
LANG_UPDATES_AVAILABLE="Доступные обновления"
LANG_UPDATES_FOUND="Доступны обновления пакетов"
LANG_UPDATES_FOUND_FIX="apt update && apt upgrade -y"
LANG_UPDATES_OK="Система обновлена"
LANG_AUTO_UPDATES="Автообновления"
LANG_AUTO_UPDATES_ACTIVE="Автообновления безопасности настроены"
LANG_AUTO_UPDATES_INACTIVE="Автообновления не настроены"
LANG_AUTO_UPDATES_INACTIVE_FIX="apt install unattended-upgrades -y && dpkg-reconfigure -plow unattended-upgrades"

# --- Login checks ---
LANG_LAST_LOGINS="Последние 5 входов"
LANG_NO_LOGINS="История входов пуста"

# --- Help ---
LANG_HELP_TITLE="sysgate — справка"
LANG_HELP_DESC="Аудит безопасности и состояния сервера Linux/Windows."
LANG_HELP_USAGE="Использование"
LANG_HELP_OPTIONS="Параметры"
LANG_HELP_OPT_LANG="язык вывода: ru или en (по умолчанию: автодетект)"
LANG_HELP_OPT_OUTPUT="сохранить отчёт в файл (по умолчанию: sysgate-report-ДАТА.txt)"
LANG_HELP_OPT_NO_SAVE="не сохранять отчёт в файл"
LANG_HELP_OPT_SECTION="запустить только один раздел: system, network, ssh, firewall, security, updates"
LANG_HELP_LEGEND="Обозначения"
LANG_HELP_PASS="всё в порядке"
LANG_HELP_WARN="рекомендуется исправить"
LANG_HELP_FAIL="исправить немедленно"
LANG_HELP_INFO="информация"
LANG_HELP_EXAMPLES="Примеры"
LANG_HELP_EXAMPLE_1="полный аудит на русском"
LANG_HELP_EXAMPLE_2="только проверка SSH"
LANG_HELP_EXAMPLE_3="сохранить отчёт в файл"
LANG_HELP_EXAMPLE_4="без сохранения отчёта"
