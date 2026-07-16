# Account Profile Completion Analysis
## Fluxo de Criação de Conta e Conclusão do Perfil — Diagnóstico Completo

**Data da análise:** 2026-07-14  
**Status:** ✅ Problema identificado e causa raiz confirmada  
**Escopo:** Flutter (Brawe App) + Backend (Brawe Connect)

---

## 📋 Resumo Executivo

O usuário cria conta, completa perfil com sucesso, dados são salvos no backend, **MAS a aplicação não direciona o usuário para nenhuma tela**. A tela de completar perfil permanece aberta.

### Causa Raiz Confirmada
O `EditProfileScreen.dart` **não atualiza o `authStateProvider`** após salvar os dados. O router observa `authStateProvider`, vê o usuário antigo (ainda sem `avatarUrl`), redireciona de volta para `/edit-profile`, criando um loop invisível.

### Diferença com Fluxos Funcionais
- ✅ `LoginViewModel`: Chama `ref.read(authStateProvider.notifier).updateSession(user)` após login bem-sucedido
- ✅ `SignupViewModel`: Chama `ref.read(authStateProvider.notifier).updateSession(user)` após cadastro bem-sucedido
- ❌ `EditProfileScreen`: **NÃO chama** `updateSession()` após salvar perfil

---

## 🔍 Descrição do Bug

### Fluxo Atual (Quebrado)
```
1. Usuário cria conta → backend: POST /auth/register/affiliate
   ✓ Conta criada
   ✓ Token gerado e salvos
   ✓ authStateProvider.updateSession(user) chamado
   ✓ Usuário autenticado, mas avatarUrl == null

2. Router detecta: user.avatarUrl vazio
   ✓ Redireciona para /edit-profile

3. Usuário preenche formulário
   - displayName
   - username
   - bio
   - social links
   - avatar (upload)

4. Usuário toca "Salvar"
   ✓ Backend: PUT /profile/me (displayName, bio, social links)
   ✓ Backend: PUT /users/me/username (username)
   ✓ Backend: POST /profile/me/avatar (avatar upload)
   ✓ Dados persistidos no banco
   ✓ Flutter local: editProfileViewModelProvider atualizado

5. Após sucesso:
   ✓ Mostra SnackBar "Perfil salvo"
   ✗ NÃO atualiza authStateProvider
   ✗ NÃO invalida cache
   ✗ NÃO navega

6. Router continua observando authStateProvider
   ✗ Vê user.avatarUrl ainda vazio (versão antiga)
   ✗ Redireciona para /edit-profile novamente
   ✗ Usuário vê tela congelada ou volta para edit-profile

7. Resultado:
   ✗ Usuário fica preso em /edit-profile
   ✗ Não consegue acessar feed ou perfil
   ✗ Experiência confusa
```

### Fluxo Esperado (Feed)
```
1. Usuário cria conta → autenticado, avatarUrl vazio
2. Router redireciona para /edit-profile
3. Usuário salva perfil com avatar
4. EditProfileScreen atualiza authStateProvider
5. Router vê user.avatarUrl preenchido
6. Router permite navegação para /home (feed)
```

---

## 🗺️ Mapeamento Completo do Fluxo

### FASE 1 — Arquivos Flutter (Cadastro → Autenticação)

| Arquivo | Classe/Provider | Responsabilidade | Status |
|---------|-----------------|------------------|--------|
| `lib/main.dart` | Main | Entry point da aplicação | ✓ Inicializa |
| `lib/routing/router.dart` | `routerProvider` GoRouter | Router principal com redirect logic | ✓ Funcionando |
| `lib/ui/auth/widgets/welcome_screen.dart` | `WelcomeScreen` | Splash com "Login" / "Signup" | ✓ Ok |
| `lib/ui/auth/widgets/signup_screen.dart` | `SignupScreen` | Tela de cadastro (name, email, password) | ✓ Ok |
| `lib/ui/auth/view_models/signup_view_model.dart` | `SignupViewModel` | Gerencia estado do signup, chama authStateProvider.updateSession() | ✓ Correto |
| `lib/ui/auth/widgets/login_screen.dart` | `LoginScreen` | Tela de login | ✓ Ok |
| `lib/ui/auth/view_models/login_view_model.dart` | `LoginViewModel` | Gerencia estado do login, chama authStateProvider.updateSession() | ✓ Correto |
| `lib/data/repositories/auth_repository.dart` | `AuthRepository` | Faz chamadas de auth (registerAffiliate, login, getCurrentUser) | ✓ Ok |
| `lib/data/services/auth_service.dart` | `AuthService` | Endpoints: /auth/register/affiliate, /auth/login, /auth/me | ✓ Ok |
| `lib/data/repositories/auth_state_provider.dart` | `AuthState` (Notifier) | Estado autenticado do usuário | ✓ Ok |
| `lib/data/services/storage_service.dart` | `StorageService` | Persist token (FlutterSecureStorage) e user (JSON) | ✓ Ok |

### FASE 2 — Tela de Completar Perfil (Crítica)

| Aspecto | Localização | Achado | Status |
|--------|------------|--------|--------|
| **Arquivo da tela** | `lib/ui/edit_profile/widgets/edit_profile_screen.dart` | Class: `EditProfileScreen`, StatefulWidget com ConsumerState | ✓ Encontrado |
| **Widget principal** | Mesma | `_EditProfileScreenState` | ✓ Encontrado |
| **Controller/Provider** | `lib/ui/edit_profile/view_models/edit_profile_view_model.dart` | `EditProfileViewModel` (StateNotifier) | ✓ Ok |
| **Método salvar** | `edit_profile_screen.dart` linha 91-156 | `_onSave()` → lê editProfileViewModelProvider.notifier.save() | ✓ Encontrado |
| **O que _onSave() faz** | Linhas 91-156 | 1. save() perfil; 2. saveUsername(); 3. registerArtistIfNeeded(); 4. showSnack | ✓ Ok |
| **Após sucesso** | Linha 155 | `_showSnack(S.of(context).editProfileSaved);` **e depois...** | ❌ **NADA** |
| **Navegação** | `edit_profile_screen.dart` | Procurado: Navigator.push, context.go, router.refresh → **VAZIO** | ❌ **NÃO EXISTE** |
| **Atualização do authState** | Procurado em todo edit_profile/** | `authStateProvider.notifier.updateSession()` → **VAZIO** | ❌ **NÃO EXISTE** |
| **Invalidation de cache** | Procurado em todo edit_profile/** | `ref.invalidate()` ou `ref.refresh()` → **VAZIO** | ❌ **NÃO EXISTE** |

### FASE 3 — Endpoints Backend

#### PUT /profile/me — Atualizar Perfil

**Arquivo:** `/Users/josecarlosmartins/Documents/Brawe/brawe-connect/backend/app/api/v1/profile.py` (linhas ~229-243)

```python
@router.put("/me")
async def update_my_profile(
    data: UpdateProfileRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
```

- **Método HTTP:** `PUT`
- **Rota:** `/profile/me`
- **Autenticação:** ✓ Requer JWT token
- **Request body (UpdateProfileRequest):**
  ```python
  {
    "display_name": str (opcional),
    "bio": str (opcional),
    "social_links": dict (opcional),
    "account_type": str (opcional)
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "user_id": "uuid",
      "username": "string",
      "display_name": "string",
      "bio": "string",
      "avatar_url": "url",
      "banner_url": "url",
      "social_links": {},
      "account_type": "consumer",
      "followers_count": 0,
      "created_at": "iso-string"
    }
  }
  ```
- **Status HTTP:** `200 OK`
- **Crítico:** Response inclui `avatar_url` (pode estar vazio se não foi enviado upload)

#### POST /profile/me/avatar — Upload Avatar

**Arquivo:** Mesma, linhas ~368-421

```python
@router.post("/me/avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
```

- **Método HTTP:** `POST`
- **Rota:** `/profile/me/avatar`
- **Content-Type:** `multipart/form-data`
- **Request:** File upload (multipart form field: `file`)
- **Response:**
  ```json
  {
    "success": true,
    "avatar_url": "https://cdn-url/avatar-123.jpg",
    "message": "Foto de perfil atualizada com sucesso"
  }
  ```
- **Status HTTP:** `200 OK`
- **Persistência:** Atualiza tanto Connect quanto Brawe (usuarios principal)
- **Crítico:** ✓ Backend atualiza a coluna `users.avatar_url` **E** `user_profiles.avatar_url`

#### PUT /users/me/username — Atualizar Username

**Arquivo:** `/Users/josecarlosmartins/Documents/Brawe/backend/app/api/v1/endpoints/users.py` linhas ~300-345

```python
@router.put("/me/username")
async def update_username(
    data: dict,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
```

- **Método HTTP:** `PUT`
- **Rota:** `/users/me/username`
- **Request:** `{"username": "novo_username"}`
- **Response:**
  ```json
  {
    "success": true,
    "message": "Username atualizado com sucesso",
    "new_username": "novo_username"
  }
  ```
- **Status HTTP:** `200 OK` (sucesso) ou `409 CONFLICT` (já em uso)

#### GET /users/check-username/{username} — Verificar Disponibilidade

- **Método HTTP:** `GET`
- **Rota:** `/users/check-username/{username}`
- **Response:**
  ```json
  {
    "available": true/false,
    "reason": "mensagem",
    "suggestions": ["sugestão1", "sugestão2"]
  }
  ```

### FASE 4 — Backend: Persistência e Resposta

**Confirmado:**
- ✓ Avatar é persistido em `users.avatar_url` (banco Brawe principal)
- ✓ Avatar é persistido em `user_profiles.avatar_url` (banco Connect)
- ✓ Username é persistido em `users.username` (banco Brawe principal)
- ✓ Display name é persistido em `user_profiles.display_name` (banco Connect)
- ✓ Endpoint PUT /profile/me devolve usuário atualizado
- ✓ Endpoint POST /profile/me/avatar devolve URL completa
- ✓ Não existe flag explícita `profileCompleted` — é determinado por `avatarUrl != null`

**Não existe:**
- ❌ Campo `profile_completed` ou `onboarding_completed` na resposta
- ❌ Field `requires_profile_completion` na resposta

### FASE 5 — Flutter Após Sucesso da API

#### Fluxo no EditProfileScreen._onSave()

```dart
Future<void> _onSave() async {
  // 1. Validar formulário
  if (!(_formKey.currentState?.validate() ?? false)) return;
  
  // 2. Coletar dados
  final socialLinks = <String, String>{};
  // ... build socialLinks ...
  
  // 3. Chamar EditProfileViewModel.save()
  final ok = await ref
      .read(editProfileViewModelProvider.notifier)
      .save(
        displayName: _nameCtrl.text,
        bio: _bioCtrl.text,
        socialLinks: socialLinks,
        accountType: ref
            .read(editProfileViewModelProvider)
            .value
            ?.effectiveAccountType,
      );
  
  // 4. Check if mounted (segurança)
  if (!mounted) return;
  
  // 5. Se save() retornou true:
  if (ok) {
    // 5a. Salvar username se mudou
    final vmState = ref.read(editProfileViewModelProvider).value;
    final currentUsername = vmState?.profile?.username?.toLowerCase() ?? '';
    final newUsername = _usernameCtrl.text.trim().toLowerCase();
    
    if (newUsername.isNotEmpty && newUsername != currentUsername) {
      final usernameOk = await ref
          .read(editProfileViewModelProvider.notifier)
          .saveUsername(newUsername);
      
      if (!mounted) return;
      
      if (!usernameOk) {
        _showSnack(
          S.of(context).editProfileSavedUsernameFailed,
          isError: true,
        );
        return;  // ← RETORNA AQUI SE FALHAR
      }
    }
    
    // 5b. Registrar artista se necessário
    if (ok) {
      final mf = musicianFieldsKey.currentState;
      if (mf != null) {
        await ref
            .read(editProfileViewModelProvider.notifier)
            .registerArtistIfNeeded(...);
      }
    }
    
    // 5c. MOSTRAR SNACK E... FIM
    _showSnack(S.of(context).editProfileSaved);
    
    // ❌ FALTA AQUI:
    // ref.read(authStateProvider.notifier).updateSession(updatedUser);
    // ref.refresh(authStateProvider);
    // context.go('/home');
    // ou
    // context.go('/profile');
  }
}
```

**O que falta:**
1. ❌ Não carrega o usuário atualizado do backend
2. ❌ Não atualiza `authStateProvider`
3. ❌ Não invalida cache
4. ❌ Não navega para nenhum lugar
5. ❌ Método simplesmente retorna

**Consequência:**
- Router observa `authStateProvider`
- Vê `user.avatarUrl` vazio (versão antiga)
- Redireciona de volta para `/edit-profile`
- Loop invisível

### FASE 6 — Router e Guards

**Arquivo:** `lib/routing/router.dart` linhas 71-111

```dart
@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);  // ← OBSERVA AQUI

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: RouterRefreshListenable(ref),  // ← REATIVA quando authState muda
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.asData?.value;  // ← USER ATUAL
      final isAuth = user != null;
      
      // ... lógica de login/logout ...
      
      // ── GATE DE AVATAR (Crítico) ──────────────────
      final avatar = user.avatarUrl?.trim() ?? '';
      final needsAvatar = avatar.isEmpty;  // ← DETERMINA SE PRECISA COMPLETAR PERFIL
      final isOnEditProfile = state.matchedLocation == '/edit-profile';
      final isOnSettings = state.matchedLocation.startsWith('/settings');
      
      if (needsAvatar && !isOnEditProfile && !isOnSettings) {
        return '/edit-profile';  // ← FORCE REDIRECT
      }
      
      return null;  // Permite navegação normal
    },
    // ... rotas ...
  );
}
```

**Como funciona:**
1. `authStateProvider` é observado pelo router
2. Quando `authStateProvider` muda, `RouterRefreshListenable` notifica o router
3. Router chama a função `redirect` novamente
4. Se `user.avatarUrl` vazio → redireciona para `/edit-profile`
5. Se `user.avatarUrl` preenchido → libera navegação

**Problema:**
- Após salvar perfil em `EditProfileScreen`, `authStateProvider` **NÃO é atualizado**
- Router continua vendo user antigo
- Guard continua retornando `/edit-profile`

### FASE 7 — Upload do Avatar

**Fluxo completo:**

1. **Usuário toca avatar na tela**
   - Seleciona foto da galeria
   - Sistema abre editor de imagem (corte)
   - Usuário confirma corte

2. **Código chama `uploadAvatarFromPath(path)`**
   - `EditProfileViewModel.uploadAvatarFromPath(String path)`
   - Arquivo: `edit_profile_view_model.dart` linhas 267-284

3. **Upload acontece**
   ```dart
   Future<void> uploadAvatarFromPath(String path) async {
     final current = state.value;
     if (current == null) return;
     try {
       state = AsyncValue.data(
           current.copyWith(isUploadingAvatar: true, clearError: true));
       
       final repo = ref.read(profileRepositoryProvider);
       final url = await repo.uploadAvatar(path);  // ← POST /profile/me/avatar
       
       final updated = current.profile?.copyWith(avatarUrl: url);
       state = AsyncValue.data(current.copyWith(
         profile: updated,
         isUploadingAvatar: false,
       ));
     } catch (e) {
       state = AsyncValue.data(state.value!.copyWith(
         isUploadingAvatar: false,
         error: EditProfileErrorCode.avatarUploadFailed,
       ));
     }
   }
   ```

4. **Resposta**
   - Backend retorna `{"success": true, "avatar_url": "https://..."}`
   - Local: `editProfileViewModelProvider` atualizado (mas `authStateProvider` não)

**Crítico:**
- Avatar é persistido no backend ✓
- Avatar é retornado na resposta ✓
- `editProfileViewModelProvider` é atualizado ✓
- `authStateProvider` é atualizado ❌

### FASE 8 — Destino Após Salvamento

#### Análise das Opções

| Opção | Coerência | Alteração | Risco | Recomendado |
|-------|-----------|-----------|-------|-------------|
| **Feed (/home)** | Alto — é a tela padrão após login bem-sucedido | Média — need router refresh | Baixo — padrão no projeto | ✅ **SIM** |
| **Perfil (/profile/[userId])** | Médio — confirma dados salvos, mas cria fluxo diferente | Média — need to pass userId | Médio — pode confundir sequência | ❌ Não recomendado |

**Recomendação:** **FEED**

Razão: Novo usuário deve ir direto ao feed após onboarding completo, assim como usuários que fazem login. É o padrão esperado.

---

## 🐛 Análise de Bugs e Riscos

### Bug Identificado

| Bug/Risco | Causa Provável | Evidência | Arquivos Envolvidos |
|-----------|---|---|---|
| **Usuário preso em edit-profile** | EditProfileScreen não atualiza authStateProvider | `_onSave()` termina sem chamar `updateSession()` | `edit_profile_screen.dart`, `router.dart`, `auth_state_provider.dart` |
| **Router não reconhece perfil completo** | authStateProvider não foi notificado | `authState.asData?.value` contém user antigo (avatarUrl == null) | `router.dart` observa authStateProvider |
| **Usuario não consegue navegar** | Guard redireciona de volta para edit-profile | Condição `needsAvatar` permanece true | `router.dart` redirect logic |
| **Experiência confusa** | App silenciosamente redireciona | Sem erro, sem loading, tela parece congelada | `edit_profile_screen.dart` não navega |

### Riscos de Implementação Futura

| Risco | Severidade | Como Mitigar |
|-------|-----------|------------|
| Se navegar antes de updateSession, guard pode bloquear novamente | Alto | Validar que authState foi atualizado antes de navegar |
| Se fazer update async sem await, race condition | Alto | Usar async/await corretamente |
| Se aplicar no ProfileEditScreen mas não atualizar parametros do User model | Médio | Testar que User.fromJson() recebe todos os campos |
| Se criar request duplicado por double-click | Médio | Desabilitar botão durante saving (já feito no AppBar) |
| Se versão publicada do app tentar ler campo novo que backend não retorna | Alto | Testar retrocompatibilidade — backend deve manter contrato |
| Se state fica inconsistente (username no banco, mas user model não tem) | Médio | Chamar `authRepository.getCurrentUser()` após salvar |

---

## 🔧 Possibilidade de Hotfix Backend

### Análise

**A:** Existe correção backend que resolve para a versão publicada?
- ❌ **NÃO**. O problema é que o Flutter não atualiza seu estado local. O backend já está correto.

**B:** Essa correção é realmente suficiente?
- N/A — não há correção backend suficiente.

**C:** A correção definitiva precisa ocorrer no Flutter?
- ✅ **SIM**. O Flutter precisa chamar `authStateProvider.notifier.updateSession()` após salvar.

**D:** É possível aplicar hotfix backend temporário e depois publicar correção Flutter?
- ❌ **NÃO**. O problema não está no backend.

**E:** Qual opção tem menor risco?
- ✅ Correção **exclusivamente Flutter** tem menor risco.

### Conclusão
- Backend está funcionando corretamente ✓
- Nenhum hotfix backend será necessário
- Correção deve ser **exclusivamente no Flutter**
- Aplicativo publicado não precisa esperar por nova versão backend

---

## 🔄 Comparação com Fluxos Funcionais

### Login Bem-Sucedido (Funciona ✓)

**Arquivo:** `lib/ui/auth/view_models/login_view_model.dart` linhas 68-82

```dart
Future<bool> submit() async {
  // ... validação ...
  try {
    final user = await ref
        .read(authRepositoryProvider)
        .login(state.email, state.password);
    state = state.copyWith(status: AsyncValue.data(user));
    
    // ✅ CHAMA AQUI:
    ref.read(authStateProvider.notifier).updateSession(user);
    
    // Registra push notification
    unawaited(ref.read(pushNotificationServiceProvider).registerWithBackend());
    return true;
  } on Failure catch (e, st) {
    // ... handle error ...
  }
}
```

**O que funciona:**
1. Faz request para `/auth/login`
2. Recebe user com avatar (ou sem, se novo)
3. **Atualiza authStateProvider**
4. Router vê mudança
5. Se avatar vazio → redireciona para `/edit-profile`
6. Se avatar preenchido → vai para `/home`

### Signup Bem-Sucedido (Funciona ✓)

**Arquivo:** `lib/ui/auth/view_models/signup_view_model.dart` linhas 102-115

```dart
try {
  final user = await ref
      .read(authRepositoryProvider)
      .registerAffiliate(
        email: state.email,
        password: state.password,
        name: state.name,
        sponsorCode: state.sponsorCode,
        termsAccepted: state.termsAccepted,
        privacyAccepted: state.termsAccepted,
      );
  state = state.copyWith(status: AsyncValue.data(user));
  
  // ✅ CHAMA AQUI:
  ref.read(authStateProvider.notifier).updateSession(user);
  
  return true;
}
```

**O que funciona:**
1. Faz request para `/auth/register/affiliate`
2. Recebe user (novo, sem avatar)
3. **Atualiza authStateProvider**
4. Router vê mudança
5. Redireciona para `/edit-profile` (pois avatar vazio)

### EditProfile (Quebrado ❌)

**Arquivo:** `lib/ui/edit_profile/widgets/edit_profile_screen.dart` linhas 91-156

```dart
Future<void> _onSave() async {
  // ... validação ...
  
  final ok = await ref
      .read(editProfileViewModelProvider.notifier)
      .save(...);
  
  if (!mounted) return;
  
  if (ok) {
    // ... save username ...
    // ... register artist ...
    
    // ❌ FALTA AQUI:
    // ref.read(authStateProvider.notifier).updateSession(?);
    
    // Apenas mostra snack:
    _showSnack(S.of(context).editProfileSaved);
  }
}
```

**O que não funciona:**
1. Faz requests para `/profile/me`, `/users/me/username`, `/profile/me/avatar`
2. Recebe responses com dados atualizados
3. **MAS NÃO ATUALIZA authStateProvider**
4. Router continua vendo user antigo
5. Redireciona de volta para `/edit-profile`

---

## 📊 Análise da Pilha de Navegação

### Estrutura Atual

```
Router (GoRouter)
├── /welcome (WelcomeScreen)
├── /login (LoginScreen)
├── /signup (SignupScreen)
├── /edit-profile (EditProfileScreen) ← FORÇA-REDIRECT AQUI
└── ShellRoute (HomeBottomNav)
    ├── /home (ForYouScreen)
    ├── /feed (FeedScreen)
    ├── /explore (ExploreScreen)
    ├── /profile/:userId (ProfileScreen)
    └── ... (outras rotas internas)
```

### Problema de Navegação

1. Usuário cria conta → autenticado com `avatarUrl == null`
2. Router redirect: não pode ir a `/home`, força `/edit-profile`
3. Usuário completa perfil
4. `_onSave()` NÃO atualiza authStateProvider
5. Router NÃO recebe notificação de mudança
6. Permanece em `/edit-profile`
7. Se usuário tenta voltar (back button), volta para `/welcome` (erro UX)

### Solução Recomendada

Após `_onSave()` sucesso:
```dart
// 1. Obter usuário atualizado do backend
final updatedUser = await ref
    .read(authRepositoryProvider)
    .getCurrentUser();

// 2. Atualizar authStateProvider
ref.read(authStateProvider.notifier).updateSession(updatedUser);

// 3. Aguardar router reconhecer mudança
await Future.delayed(Duration(milliseconds: 100)); // Micro-delay se necessário

// 4. Navegar para feed
if (mounted) {
  context.go('/home');
  // ou
  context.replace('/home');
}
```

---

## ✅ Critérios de Aceite da Correção Futura

A correção estará concluída quando:

- [ ] Formulário valida corretamente (já funciona)
- [ ] Perfil é salvo (nome, bio, links sociais)
- [ ] Username é salvo
- [ ] Foto é enviada e persistida
- [ ] Loading encerra
- [ ] ✅ **Usuário autenticado é atualizado com novos dados**
- [ ] ✅ **`authStateProvider` é notificado de mudança**
- [ ] ✅ **Cache é invalidado (se houver)**
- [ ] Router reconhece novo estado (`avatarUrl` preenchido)
- [ ] ✅ **Usuário é enviado ao feed (/home) sem redirecionar de volta**
- [ ] ✅ **Pilha de navegação é limpa (não volta a edit-profile ao tocar back)**
- [ ] Reiniciar app abre a área autenticada (feed), não edit-profile
- [ ] Fazer login novamente abre a área autenticada
- [ ] Erro no upload não deixa estado inconsistente
- [ ] Duplo clique não cria requests duplicados
- [ ] Versões antigas não sofrem regressão
- [ ] Não existe loop de redirecionamento

---

## 📝 Plano de Correção por Fases

### FASE A — Corrigir Salvamento e Atualização de Estado

**Arquivos:** 
- `lib/ui/edit_profile/widgets/edit_profile_screen.dart`
- `lib/ui/edit_profile/view_models/edit_profile_view_model.dart`

**Alteração futura:**
```dart
// Em _onSave(), após sucesso:
if (ok) {
  // ... salvar username e artista (já existe) ...
  
  // Novo: Obter usuário atualizado
  final updatedUser = await ref
      .read(authRepositoryProvider)
      .getCurrentUser();
  
  // Novo: Atualizar authState
  ref.read(authStateProvider.notifier).updateSession(updatedUser);
}
```

**Dependências:** 
- `authRepositoryProvider`
- `authStateProvider` e seu notifier

**Risco:** Baixo — padrão já usado em LoginViewModel e SignupViewModel

**Critério de aceite:** 
- authStateProvider foi atualizado com novo user
- User tem avatarUrl preenchido

---

### FASE B — Garantir Cache Invalidado

**Arquivos:**
- `lib/ui/edit_profile/widgets/edit_profile_screen.dart` (continuação)

**Alteração futura:**
Se houver outras providers que cacheiam perfil, invalide-as:
```dart
// Opcional: invalidar cache de perfil
ref.invalidate(profileViewModelProvider);
// ou
ref.refresh(profileViewModelProvider);
```

**Risco:** Mínimo — invalidação é sempre segura

---

### FASE C — Atualizar Router e Navegar

**Arquivos:**
- `lib/ui/edit_profile/widgets/edit_profile_screen.dart`

**Alteração futura:**
```dart
// Após atualizar authState:
if (mounted) {
  // Go to feed (novo usuário recém-completo vai ao feed)
  context.go('/home');
  
  // Alternativa se preferir perfil:
  // final userId = updatedUser.id;
  // context.go('/profile/$userId');
}
```

**Risco:** Baixo — já usado em outras telas

**Critério de aceite:** 
- Tela muda de /edit-profile para /home
- Back button não retorna a edit-profile

---

### FASE D — Testes de Regressão

**Arquivos:**
- Todos acima, mais:
- `lib/routing/router.dart` (verificar guard)
- `lib/ui/auth/view_models/login_view_model.dart` (não quebrar)
- `lib/ui/auth/view_models/signup_view_model.dart` (não quebrar)

**Testes:**
```
[ ] Login normal → feed
[ ] Signup → edit-profile (avatar vazio)
[ ] Completar perfil → feed (novo fluxo)
[ ] Voltar do feed → não retorna a edit-profile
[ ] Reiniciar app → abre feed
[ ] Logout e login novamente → feed
[ ] Username duplicado → erro tratado
[ ] Avatar grande → comprimido ou rejeitado
```

**Risco:** Médio — precisa testar todo fluxo de onboarding

---

## 📈 Matriz de Arquivos e Problemas

| Etapa | Arquivo | Comportamento Atual | Problema | Correção Futura |
|-------|---------|---------------------|---------|-----------------|
| 1. Cadastro | `signup_screen.dart` | Cria conta, chama updateSession | Nenhum | Nenhuma necessária |
| 2. Detecta avatar vazio | `router.dart` (redirect) | Redireciona para `/edit-profile` | Nenhum | Nenhuma necessária |
| 3. Tela de editar perfil | `edit_profile_screen.dart` | Carrega formulário | Nenhum | Nenhuma necessária |
| 4. Salvar perfil | `edit_profile_view_model.dart::save()` | Persiste displayName, bio, links | Nenhum | Nenhuma necessária |
| 5. Salvar username | `edit_profile_view_model.dart::saveUsername()` | Persiste username | Nenhum | Nenhuma necessária |
| 6. Upload avatar | `edit_profile_view_model.dart::uploadAvatarFromPath()` | Persiste URL em backend | Nenhum | Nenhuma necessária |
| 7. Sucesso em _onSave() | `edit_profile_screen.dart::_onSave()` | Mostra snack "Salvo" | ❌ **NÃO atualiza authStateProvider** | ✅ **Chamar authStateProvider.notifier.updateSession(newUser)** |
| 8. Router observa mudança | `router.dart` | Continua vendo user antigo | ❌ **authState não foi notificado** | ✅ **Notificação viria da FASE A** |
| 9. Guard reavalia perfil | `router.dart` (redirect) | Redireciona de volta para edit-profile | ❌ **avatarUrl ainda vazio** | ✅ **avatarUrl agora preenchido** |
| 10. Navegação | `edit_profile_screen.dart` | Nenhuma | ❌ **Não navega** | ✅ **context.go('/home')** |

---

## 🎯 Opções de Correção

### OPÇÃO A — Correção Somente Flutter (Recomendada ✅)

**Precisão:** Direcionar `_onSave()` para atualizar authStateProvider após sucesso

**Arquivos:**
- `lib/ui/edit_profile/widgets/edit_profile_screen.dart` (1 alteração)
- Possivelmente `lib/ui/edit_profile/view_models/edit_profile_view_model.dart` (refactor opcional)

**Alterações Necessárias:**

1. **Em `_onSave()` após sucesso:**
   ```dart
   if (ok) {
     // ... código existente: save username, register artist ...
     
     // ✅ NOVO: Obter usuário atualizado
     try {
       final updatedUser = await ref
           .read(authRepositoryProvider)
           .getCurrentUser();
       
       // ✅ NOVO: Atualizar authState
       ref.read(authStateProvider.notifier).updateSession(updatedUser);
     } catch (e) {
       // Silencioso — perfil foi salvo mesmo se falhar
       logger.warning('Failed to update auth state: $e');
     }
     
     // ✅ NOVO: Navegar para home
     if (mounted) {
       context.go('/home');
     }
     
     _showSnack(S.of(context).editProfileSaved);
   }
   ```

2. **Imports necessários:**
   - Já existem: `authRepositoryProvider`, `authStateProvider`

**Vantagens:**
- ✅ Segue padrão existente (LoginViewModel, SignupViewModel)
- ✅ Baixo risco — muda apenas essa função
- ✅ Nova versão do app resolve para todo mundo
- ✅ Não quebra versões antigas
- ✅ Router funcionará como projetado

**Riscos:**
- Baixo risco geral, mas:
  - Possível race condition se `/auth/me` for lento (mitigado com micro-delay se necessário)
  - Possível que userData seja parcialmente preenchido (mitigado por estar usando authRepository que conhece fallbacks)

**Testes:**
```
[ ] Novo usuário completa perfil → vai a /home
[ ] Back do home não retorna a edit-profile
[ ] Voltar a /edit-profile da home atualiza dados
[ ] Logout e login → feed (sem edit-profile)
[ ] Reiniciar app → feed
```

**Compatibilidade:**
- ✅ Versão publicada não será afetada
- ✅ Próxima versão (fix) resolve para novo instalar
- ✅ Hotfix/update via store quando pronto

---

### OPÇÃO B — Correção Somente Backend (NÃO Viável ❌)

**Hipótese:** Backend poderia enviar um campo que forçasse redirect no app

**Problema:**
- Backend já está retornando os dados corretos
- Problema é que Flutter não atualiza seu estado local
- Não há solução backend que force o app publicado a navegar
- Backend não pode controlar navegação nativa

**Conclusão:** ❌ **NÃO é uma opção válida**

---

### OPÇÃO C — Hotfix Backend + Correção Flutter (Desnecessário)

**Cenário:** Se backend estivesse quebrado

**Status:** Backend está funcionando perfeitamente
- ✓ Avatar é persistido
- ✓ Username é persistido
- ✓ Response retorna usuário atualizado
- ✓ Sem campos faltando

**Conclusão:** ❌ **Não necessário — opção B não é viável anyway**

---

## 🎖️ Recomendação Final

### Opção Recomendada: **OPÇÃO A — Correção Somente Flutter**

**Razão:**
1. Backend está funcionando ✓
2. Problema é 100% no Flutter ✓
3. Solução é simples e segura ✓
4. Padrão já existe no código (LoginViewModel, SignupViewModel) ✓
5. Nova versão resolve para todos ✓
6. Nenhum hotfix backend necessário ✓
7. Nenhuma versão publicada será quebrada ✓

**Próximos Passos:**
1. Claude 5 implementa OPÇÃO A
2. Teste completo do fluxo de onboarding
3. Build de release (iOS TestFlight + Android Play Store)
4. Testes de regressão com usuários reais
5. Release progressivo

---

## 📌 Checklist de Implementação para Claude 5

- [ ] Ler este documento completo
- [ ] Validar que authRepositoryProvider é acessível em edit_profile_screen.dart
- [ ] Adicionar import de authStateProvider se necessário
- [ ] Modificar `_onSave()` conforme OPÇÃO A
- [ ] Adicionar tratamento de erro para chamada a getCurrentUser()
- [ ] Testar que authState foi atualizado antes de navegar
- [ ] Testar que router reconhece mudança e não redireciona de volta
- [ ] Verificar que versão publicada não quebra
- [ ] Build e release

---

## 📍 Pontos Não Confirmados

| Ponto | Motivo | Recomendação |
|-------|--------|-------------|
| Exato tempo de reload do avatar CDN | Network depende de Cloudflare e DO Spaces | Testar em produção com 4G lenta |
| Se existe fallback em caso de getCurrentUser() falhar | authRepository tem fallback para local storage | Deve funcionar, mas testar |
| Se router detecta mudança em tempo real ou precisa de delay | Depende de GoRouter internals | Testar — possível micro-delay necessário |
| Se avatar é obrigatório ou pode ser adicionado depois | Código trata como obrigatório (gate em router) | Seguir código atual |

---

## 📞 Conclusão

**Status:** ✅ Análise completa  
**Causa raiz:** ✅ Identificada  
**Solução:** ✅ Mapeada  
**Risco:** Baixo  
**Urgência:** Alta (novo usuário não consegue onboardear)

A correção é **simples, segura e de baixo risco**. EditProfileScreen deve chamar `authStateProvider.notifier.updateSession()` após sucesso, seguindo o padrão já estabelecido em LoginViewModel e SignupViewModel.

**Encaminhar para implementação OPÇÃO A.**

---

**Data de análise:** 2026-07-14  
**Analisador:** Engenheiro de Diagnóstico (Flutter/FastAPI/State Management)  
**Próxima fase:** Implementação por Claude 5
