FPS / NewVanillaPatch — публикация обновления alpha43 через GitHub Releases

Почему этот вариант лучше
==========================
GitHub через браузер ограничивает обычную загрузку файла в репозиторий 25 MiB.
Godot FPS.exe может быть больше этого лимита. Поэтому EXE публикуется как asset
в GitHub Release, а в корень ветки main загружается только маленький manifest.json.

ВАЖНО
=====
Репозиторий ARG303/NewVanillaPatch должен быть PUBLIC.
Лаунчер alpha43 читает manifest без GitHub-токена по адресу raw.githubusercontent.com.
Если репозиторий Private, в лаунчере будет GITHUB ERROR/RETRY.

Как публиковать
===============
1. Экспортируй рабочий RELEASE-билд Godot как FPS.exe.
2. Положи FPS.exe рядом с prepare_release_update.bat
   или перетащи FPS.exe мышкой на BAT.
3. Запусти prepare_release_update.bat.
4. После выполнения будут готовы:

   RELEASE_ASSET\FPS.exe
   UPLOAD_MANIFEST_TO_REPO\manifest.json

5. На GitHub открой ARG303/NewVanillaPatch -> Releases -> Draft a new release.
6. Создай НОВЫЙ tag:

   v1.0.0-alpha43

7. Прикрепи к Release файл:

   RELEASE_ASSET\FPS.exe

   Имя asset должно остаться ТОЧНО "FPS.exe".

8. Нажми Publish release.
9. После публикации Release загрузи только файл:

   UPLOAD_MANIFEST_TO_REPO\manifest.json

   в КОРЕНЬ ветки main репозитория.

10. Проверь в браузере, что открывается manifest.json через кнопку Raw.
11. Запусти launcher. У alpha43 должно быть GITHUB • SYNCED.
    Более старая версия должна увидеть UPDATE • v1.0.0-alpha43.

Если launcher показывает GITHUB ERROR
=====================================
Проверь три вещи:
- repository Visibility = Public;
- ветка называется именно main;
- manifest.json лежит в самом корне main, а не в подпапке.

Если в GitHub Release файл переименован, ссылка из manifest перестанет работать.
Оставляй имя FPS.exe.
