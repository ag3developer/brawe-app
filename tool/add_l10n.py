#!/usr/bin/env python3
"""Adiciona textos às traduções (pt, en, es) com trava de arquivo.

Uso:
    python3 tool/add_l10n.py caminho/para/novas_chaves.json

O JSON tem o formato:
    {
      "chaveNova": {"pt": "Texto", "en": "Text", "es": "Texto"},
      "comParametro": {"pt": "Olá {name}", "en": "Hi {name}", "es": "Hola {name}",
                       "placeholders": {"name": "String"}}
    }

- Falha se a chave já existir (escolha outro nome).
- Seguro para vários processos ao mesmo tempo (trava exclusiva).
- Depois rode: flutter gen-l10n
"""
import fcntl
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARB = {lang: ROOT / f"lib/l10n/app_{lang}.arb" for lang in ("pt", "en", "es")}
LOCK = ROOT / "lib/l10n/.arb.lock"


def main() -> None:
    new = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    with open(LOCK, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        texts = {lang: p.read_text(encoding="utf-8") for lang, p in ARB.items()}
        current = {lang: json.loads(t) for lang, t in texts.items()}
        for key, val in new.items():
            for lang in ARB:
                if key in current[lang]:
                    sys.exit(f"chave já existe: {key} ({lang})")
                if not val.get(lang):
                    sys.exit(f"falta tradução '{lang}' para {key}")
        for lang, path in ARB.items():
            items = []
            for key, val in new.items():
                items.append((key, val[lang]))
                if lang == "pt" and val.get("placeholders"):
                    items.append((
                        "@" + key,
                        {"placeholders": {n: {"type": t} for n, t in val["placeholders"].items()}},
                    ))
            body = texts[lang].rstrip()
            assert body.endswith("}")
            body = body[:-1].rstrip()
            body += "".join(
                f",\n  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)}" for k, v in items
            )
            path.write_text(body + "\n}\n", encoding="utf-8")
            json.loads(path.read_text(encoding="utf-8"))
        fcntl.flock(lock, fcntl.LOCK_UN)
    print(f"{len(new)} chave(s) adicionada(s). Rode: flutter gen-l10n")


if __name__ == "__main__":
    main()
