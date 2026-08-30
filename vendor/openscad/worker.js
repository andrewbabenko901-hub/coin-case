/* Расчёт STL идёт в отдельном потоке: одна половинка считается секунд
   двадцать, обе — около минуты, и в главном потоке страница на это время
   замерла бы намертво. Здесь же она остаётся живой, а прогресс приходит
   сообщениями.

   Шрифты монтируются в файловую систему движка вручную. Без этого OpenSCAD
   не находит ни одного шрифта и молча выкидывает всю гравировку — проверено:
   STL выходил на 1.2 МБ легче ровно на объём текста. */
const FONTS = [
  "LiberationSans-Regular.ttf", "LiberationSans-Bold.ttf",
  "LiberationSerif-Regular.ttf", "LiberationSerif-Bold.ttf",
  "LiberationMono-Regular.ttf", "LiberationMono-Bold.ttf",
  "DejaVuSans-Bold.ttf", "DejaVuSerif.ttf"
];
const FONTS_CONF = `<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/fonts</dir>
  <cachedir>/tmp/fontcache</cachedir>
</fontconfig>`;

/* Движок лежит в репозитории двумя кусками: цельный файл на 13.9 МБ не
   проходит через веб-загрузку файлов, поэтому он разрезан пополам и
   склеивается здесь, в браузере. Модуль импортируется из blob: URL —
   движок самодостаточен (wasm зашит внутрь, import.meta не используется),
   так что смена базового адреса на него никак не влияет. */
const ENGINE_PARTS = ["./openscad.part1.js", "./openscad.part2.js"];

async function loadEngine(){
  const base = new URL("./", import.meta.url);
  const parts = await Promise.all(ENGINE_PARTS.map(async p => {
    const r = await fetch(new URL(p, base));
    if(!r.ok) throw new Error("движок не загрузился: " + p);
    return r.text();
  }));
  const url = URL.createObjectURL(new Blob(parts, {type:"text/javascript"}));
  try { return await import(url); }
  finally { URL.revokeObjectURL(url); }
}

let ready = null;

async function boot(){
  const { createOpenSCAD } = await loadEngine();
  const oscad = await createOpenSCAD({
    printErr: t => {
      // «Cannot load default config file» приходит всегда и ни на что не
      // влияет: свой конфиг движок находит по FONTCONFIG_FILE.
      if(/Cannot load default config/.test(t)) return;
      if(/WARNING|ERROR/i.test(t)) postMessage({type:"log", text:t});
    }
  });
  const inst = oscad.getInstance(), FS = inst.FS;
  for(const d of ["/fonts", "/etc", "/etc/fonts", "/tmp", "/tmp/fontcache"])
    { try{ FS.mkdir(d); }catch(e){} }
  const base = new URL("../fonts/", import.meta.url);
  await Promise.all(FONTS.map(async name => {
    const r = await fetch(new URL(name, base));
    if(!r.ok) throw new Error("шрифт не загрузился: " + name);
    FS.writeFile("/fonts/" + name, new Uint8Array(await r.arrayBuffer()));
  }));
  FS.writeFile("/etc/fonts/fonts.conf", FONTS_CONF);
  if(inst.ENV) inst.ENV.FONTCONFIG_FILE = "/etc/fonts/fonts.conf";
  return oscad;
}

onmessage = async ev => {
  const { id, scad } = ev.data;
  try{
    postMessage({type:"stage", id, stage:"boot"});
    if(!ready) ready = boot();
    const oscad = await ready;
    postMessage({type:"stage", id, stage:"render"});
    const t0 = Date.now();
    const stl = await oscad.renderToStl(scad);
    postMessage({type:"done", id, stl, ms:Date.now()-t0});
  }catch(err){
    ready = null;                      // сломанный экземпляр не переиспользуем
    postMessage({type:"error", id, message:String(err && err.message || err)});
  }
};
