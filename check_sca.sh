#!/bin/bash
# Quality Gate для SCA: стоп при CVSS >= 7.0, отдельная проверка CVSS >= 9.0
DC="$HOME/dependency-check/bin/dependency-check.sh"
R=report/dependency-check-report.json

echo "🔍 Запуск SCA анализа..."
mkdir -p report
"$DC" \
  --project "SCA Demo" \
  --scan . \
  --exclude "**/report*/**" \
  --enableExperimental \
  --suppression dependency-check-suppression.xml \
  --format JSON --format HTML \
  --out report \
  --nvdApiKey "$NVD_API_KEY" \
  --failOnCVSS 7.0
EXIT_CODE=$?

# Оценка CVSS: v3 → v4 → v2 (поля cvssScore в отчёте нет)
SCORE='(.cvssv3.baseScore // .cvssv4.baseScore // .cvssv2.score // 0)'

if [ $EXIT_CODE -ne 0 ]; then
  echo "❌ Найдены уязвимости с CVSS >= 7.0! Сборка остановлена. (код DC: $EXIT_CODE)"
  echo "   Таких уязвимостей: $(jq "[.dependencies[].vulnerabilities[]? | select($SCORE >= 7)] | length" $R)"
  echo "📄 Отчёт: report/dependency-check-report.html"
  exit 1
fi

echo "✅ Уязвимостей с CVSS >= 7.0 не найдено."
echo "🔍 Проверка уязвимостей с CVSS >= 9.0..."
CRITICAL_COUNT=$(jq "[.dependencies[].vulnerabilities[]? | select($SCORE >= 9)] | length" $R)
if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo "❌ Найдены уязвимости с CVSS >= 9.0: $CRITICAL_COUNT"
  exit 1
fi

echo "✅ Все проверки пройдены. Продолжаем сборку."
exit 0
