#!/usr/bin/env python3
"""
Auditoria de paridade de internacionalização (i18n) entre os 3 arquivos
de localização do Brawe (pt, en, es).

Roda em ~50ms e reporta:
  1. Chaves faltando em qualquer idioma (parity check)
  2. Strings que parecem não ter sido traduzidas (heurística)
  3. Strings com placeholders {var} divergentes (que quebraria runtime)

Uso:
  python3 scripts/audit_l10n.py
  python3 scripts/audit_l10n.py --strict   # falha com exit 1 se algo errado
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARB_DIR = ROOT / 'lib' / 'l10n'

LOCALES = {
    'pt': ARB_DIR / 'app_pt.arb',
    'en': ARB_DIR / 'app_en.arb',
    'es': ARB_DIR / 'app_es.arb',
}


def load_arb(path: Path) -> dict:
    with path.open(encoding='utf-8') as f:
        data = json.load(f)
    # ignora metadados (@@locale, @key, etc.)
    return {k: v for k, v in data.items() if not k.startswith('@')}


def extract_placeholders(s: str) -> set[str]:
    """Extrai placeholders ICU como {name} ou {count, plural, ...}.

    Ignora literais dentro de blocos plural/select como =1{Enviado}, where
    "Enviado" não é placeholder, é o texto da variante. Apenas variáveis
    seguidas de `,` (ex.: `{count, plural,`) ou de `}` (ex.: `{name}`)
    são placeholders reais.
    """
    # Match {var} ou {var, plural, ...} — exige que após o nome venha `}` ou `,`
    return set(re.findall(r'\{(\w+)(?=[,}])', s))


def main() -> int:
    strict = '--strict' in sys.argv

    locales = {code: load_arb(path) for code, path in LOCALES.items()}
    pt = locales['pt']
    issues = 0

    # 1. Paridade de chaves
    print("📋 1. Paridade de chaves")
    print("─" * 60)
    pt_keys = set(pt.keys())
    for code, d in locales.items():
        if code == 'pt':
            continue
        missing = pt_keys - set(d.keys())
        extra = set(d.keys()) - pt_keys
        if missing:
            print(f"  ❌ {code.upper()}: faltam {len(missing)} chaves")
            for k in sorted(missing)[:10]:
                print(f"     • {k}")
            issues += len(missing)
        if extra:
            print(f"  ⚠️  {code.upper()}: tem {len(extra)} chaves a mais que o PT")
            for k in sorted(extra)[:10]:
                print(f"     • {k}")
        if not missing and not extra:
            print(f"  ✅ {code.upper()}: {len(d)} chaves (paridade 100%)")
    print()

    # 2. Placeholders consistentes (quebra em runtime se divergente)
    print("📋 2. Placeholders ICU consistentes")
    print("─" * 60)
    placeholder_issues = 0
    for k, pt_val in pt.items():
        if not isinstance(pt_val, str):
            continue
        pt_ph = extract_placeholders(pt_val)
        for code, d in locales.items():
            if code == 'pt' or k not in d:
                continue
            other_ph = extract_placeholders(d[k]) if isinstance(d[k], str) else set()
            if pt_ph != other_ph:
                placeholder_issues += 1
                if placeholder_issues <= 5:
                    print(f"  ⚠️  [{k}] {code.upper()}")
                    print(f"     PT: {sorted(pt_ph)}")
                    print(f"     {code.upper()}: {sorted(other_ph)}")
    if placeholder_issues == 0:
        print("  ✅ Nenhum placeholder divergente")
    else:
        issues += placeholder_issues
    print()

    # 3. Heurística: strings que claramente ainda estão em português
    print("📋 3. Heurística: frases ainda em português em outros idiomas")
    print("─" * 60)
    # Caracteres exclusivos de PT (não existem em ES nem EN)
    pt_only_chars = re.compile(r'[ãõçâê]')
    # Palavras 100% PT (não existem em ES com mesmo significado)
    pt_only_words = re.compile(r'\b(você|vocês|não|então|também)\b', re.IGNORECASE)

    # Endônimos de idiomas - é correto manter o nome nativo de cada idioma
    ENDONYMS_OK = {
        'languagePt', 'languageEs', 'languageEn',
        'settingsLanguageSubtitle',
    }

    suspicious_count = 0
    for code, d in locales.items():
        if code == 'pt':
            continue
        problems = []
        for k, v in d.items():
            if k in ENDONYMS_OK or not isinstance(v, str) or len(v) < 8:
                continue
            if pt_only_chars.search(v) or pt_only_words.search(v):
                problems.append((k, v))
        if problems:
            print(f"  ⚠️  {code.upper()}: {len(problems)} suspeitas (revisar manualmente)")
            for k, v in problems[:5]:
                print(f"     • {k}: {v[:80]}")
            if len(problems) > 5:
                print(f"     ... e mais {len(problems) - 5}")
            suspicious_count += len(problems)
        else:
            print(f"  ✅ {code.upper()}: nenhuma frase suspeita")

    print()
    print("═" * 60)
    if issues == 0 and suspicious_count == 0:
        print("✅ TUDO OK — paridade i18n completa")
        return 0
    elif issues > 0:
        print(f"❌ {issues} problemas críticos encontrados")
        return 1 if strict else 0
    else:
        print(f"⚠️  {suspicious_count} suspeitas (não-críticas) — revisar manualmente")
        return 0


if __name__ == '__main__':
    sys.exit(main())
