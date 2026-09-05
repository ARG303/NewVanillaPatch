FPS alpha43 — пакет для обновления через GitHub
================================================

Репозиторий:
ARG303/NewVanillaPatch

Лаунчер уже проверяет:
https://raw.githubusercontent.com/ARG303/NewVanillaPatch/main/manifest.json

Самый простой способ публикации alpha43:

1. Открой проект alpha43 в Godot.
2. Экспортируй RELEASE-версию Windows Desktop в FPS.exe.
   В проекте preset уже настроен на build/FPS.exe.
3. Возьми получившийся FPS.exe.
4. Положи его рядом с prepare_github_update.bat
   ИЛИ просто перетащи FPS.exe мышкой на prepare_github_update.bat.
5. Скрипт создаст папку UPLOAD_TO_GITHUB с двумя готовыми файлами:
      FPS.exe
      manifest.json
6. На GitHub открой репозиторий ARG303/NewVanillaPatch, ветку main.
7. Загрузить в КОРЕНЬ репозитория оба файла:
      FPS.exe
      manifest.json
8. Commit changes.

После этого:
- alpha42 и более старые версии увидят UPDATE • v1.0.0-alpha43;
- alpha43 покажет GITHUB • SYNCED;
- скачанный EXE будет проверяться по SHA-256, который автоматически записал BAT.

ВАЖНО:
Не используй manifest.json из папки UPLOAD_TO_GITHUB до запуска BAT вместе с
экспортированным FPS.exe, если хочешь проверку SHA-256. В исходном шаблоне SHA
пустой специально, потому что хэш зависит от конкретно собранного FPS.exe.

Если FPS.exe уже лежит в build\FPS.exe внутри проекта, можешь вызвать:
prepare_github_update.bat "полный_путь_к_build\FPS.exe"

Файлы исходников лаунчера лежат в папке SOURCE и не обязательны для автообновления.
