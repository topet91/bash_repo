#!/bin/bash

LOGFILE="access.log"
REPORT="report.txt"

# Проверяем, что файл существует
if [ ! -f "$LOGFILE" ]; then
    echo "Файл $LOGFILE не найден!"
    exit 1
fi

# 1. Общее количество запросов (количество строк в файле)
total_requests=$(wc -l < "$LOGFILE")

# 2. Количество уникальных IP-адресов (строго awk)
unique_ips=$(awk '{ips[$1]++} END {print length(ips)}' "$LOGFILE")

# 3. Количество запросов по методам (GET, POST и т.д.) (строго awk)
methods=$(awk '
{
    
    match($0, /"([A-Z]+) /, m)
    if (m[1] != "")
        count[m[1]]++
}
END {
    for (method in count)
        print method ": " count[method]
}
' "$LOGFILE")

# 4. Самый популярный URL (строго awk)

popular_url=$(awk '
{
    match($0, /"[A-Z]+ ([^ ]+) /, m)
    if (m[1] != "")
        url_count[m[1]]++
}
END {
    max = 0
    for (url in url_count) {
        if (url_count[url] > max) {
            max = url_count[url]
            popular = url
        }
    }
    print popular
}
' "$LOGFILE")

# Записываем отчет в файл
{
    echo "Отчет о логе веб-сервера"
    echo "================================="
    echo "Общее количество запросов: $total_requests"
    echo "Количество уникальных IP-адресов: $unique_ips"
    echo
    echo "Количество запросов по методам:"
    echo "$methods"
    echo
    echo "Самый популярный URL: $popular_url"
} > "$REPORT"

echo "Отчет сохранен в $REPORT"

