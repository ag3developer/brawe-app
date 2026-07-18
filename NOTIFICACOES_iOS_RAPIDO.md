# 📱 NOTIFICAÇÕES iOS - RESPOSTA RÁPIDA

## SIM! O app DEVE aparecer em Configurações

**Caminho:** `Configurações` → `Notificações` → `Brawe` (ou `Brawe App`)

---

## ✅ O que significa:

- ✅ Se aparece em Notificações → Permissão foi concedida
- ✅ Se "Permitir Notificações" está ligado → Tudo OK
- ❌ Se não aparece → Permissão nunca foi solicitada

---

## 🔧 Verificação Rápida

### 1. Abra Settings do iPhone

```
Configurações → Notificações
```

### 2. Procure por "Brawe"

- **Encontrou?** → Clique e verifique se "Permitir Notificações" está **ON**
- **Não encontrou?** → Volte ao app Brawe e aguarde a solicitação aparecer

### 3. Se não encontrou, forçar no app:

```
No app:
1. Faça logout
2. Abra o app novamente
3. Ao abrir, deve pedir permissão
4. Clique [Permitir]
5. Faça login novamente
```

---

## ⚠️ Possíveis Problemas

### "Brawe não aparece em Notificações"

**Solução:**
1. Desinstale o app completamente
2. Reinstale da App Store
3. Abra → Clique [Permitir] quando pedir
4. Agora deve aparecer em Settings

### "Brawe em Notificações mas 'Permitir' está OFF"

**Solução:**
1. Vá em Settings → Notificações → Brawe
2. Liga o switch "Permitir Notificações"
3. Volte ao app

### "Já liguei, mas notificações não chegam"

**Checklist:**
- [ ] Brawe aparece em Settings?
- [ ] "Permitir Notificações" está ON?
- [ ] Conectou à internet (WiFi ou dados)?
- [ ] Abra app, faça login e aguarde 10 segundos
- [ ] Teste: pede uma mensagem de outro device (web)

---

## 🎯 Fluxo Esperado

```
1. Abre app Brawe
   ↓
2. App pergunta: "Brawe gostaria de enviar notificações?"
   ↓
3. Você clica [Permitir]
   ↓
4. Brawe aparece em Settings → Notificações
   ↓
5. Faz login
   ↓
6. App registra token com backend
   ↓
7. Quando recebe mensagem → notificação chega!
```

---

## ✨ Tudo Implementado

Nosso app já tem:
- ✅ Solicita permissão automaticamente
- ✅ Recebe em foreground (app aberto)
- ✅ Recebe em background (app minimizado)
- ✅ Recebe quando app está fechado (APNs)
- ✅ Som, badge, notificação visual

Você só precisa:
1. **Permitir** quando o app pede
2. **Fazer login**
3. **Esperar 10 segundos**

---

## 📞 Teste Final

**Com app aberto:**
```
1. Abra Brawe no iPhone
2. Faça login
3. Peça para alguém (via web) enviar mensagem
4. Observe: deve aparecer notificação no topo da tela
```

**Com app fechado:**
```
1. Feche Brawe completamente
2. Peça para alguém (via web) enviar mensagem
3. Observe: deve aparecer no lock screen do iPhone
```

---

**Se ainda não funcionar → consulte `iOS_NOTIFICATION_SETTINGS.md` para diagnóstico completo**
