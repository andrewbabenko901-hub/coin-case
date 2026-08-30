# Сторонние компоненты

## OpenSCAD (WebAssembly)

* Файл: `vendor/openscad/openscad.js`
* Пакет: `openscad-wasm`, версия 0.0.4, npm
* Источник: https://www.npmjs.com/package/openscad-wasm
* Апстрим OpenSCAD: https://openscad.org/ — https://github.com/openscad/openscad
* Лицензия: **GNU General Public License, версия 2**

Файл включён в репозиторий без изменений, ровно в том виде, в каком он лежит
в пакете npm.

GPL-2.0 требует при распространении:

* сохранять уведомления о лицензии и авторских правах;
* обеспечивать получателям доступ к исходному коду этой части — достаточно
  ссылки на апстрим выше, поскольку компонент не изменён;
* распространять эту часть на тех же условиях.

Полный текст лицензии: https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

В самом пакете npm файла лицензии нет — поле `license` в его `package.json`
указано как `GPL-2.0`. Если хотите положить текст лицензии рядом, скачайте его
по ссылке выше и сохраните как `vendor/openscad/LICENSE-GPL-2.0.txt`.

## Шрифты

* `vendor/fonts/Liberation*.ttf` — семейство Liberation, лицензия SIL Open Font
  License 1.1. https://github.com/liberationfonts/liberation-fonts
* `vendor/fonts/DejaVu*.ttf` — семейство DejaVu, свободная лицензия DejaVu
  (на основе Bitstream Vera). https://dejavu-fonts.github.io/

Оба семейства свободно распространяются, в том числе в составе других
проектов, при сохранении уведомления о лицензии.

## IBM Plex

Интерфейс страницы использует IBM Plex, подключённый ссылкой на Google Fonts.
Лицензия SIL Open Font License 1.1. Файлы шрифта в репозиторий не входят.
