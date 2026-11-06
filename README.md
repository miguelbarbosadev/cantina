# Cantina UNIP — Trabalho NP2 (Flutter + Firebase + ViaCEP)

Tema: **Sugestão A — Cantina da faculdade (delivery)**.
Recurso adicional: **API REST com `http` + ViaCEP** (opção recomendada).

## Setup (≈15 min)

Requer **Flutter 3.35+** (por causa do `RadioGroup` da aula 08). `flutter --version` para conferir.

```bash
# 1. gerar as pastas de plataforma (web/, etc.) sem sobrescrever lib/
cd cantina_app
flutter create --platforms=web .
flutter pub get

# 2. Firebase
#   console.firebase.google.com → Novo projeto → Firestore Database → Criar (modo de teste)
dart pub global activate flutterfire_cli
flutterfire configure          # sobrescreve lib/firebase_options.dart com as chaves reais

# 3. rodar
flutter run -d chrome
```

Se o `pub get` reclamar de versão, rode `flutter pub add firebase_core cloud_firestore http` para pegar as mais novas.

**Regras do Firestore (modo teste)** — já vêm assim ao criar em modo de teste; se expirarem:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pedidos/{id} { allow read, write: if true; }
  }
}
```

**Antes da apresentação:** cadastre 3 pedidos pelo próprio app (RF exige ≥ 3 documentos reais) e deixe o console do Firestore aberto na coleção `pedidos`.

## Estrutura

```
lib/
  main.dart                 runApp, MaterialApp, Firebase.initializeApp
  theme.dart                cor e AppBar padrão (title, centerTitle, backgroundColor)
  firebase_options.dart     gerado pelo flutterfire configure
  models/produto.dart       Produto, Adicional, enum Tamanho, cardápio
  services/viacep_service.dart   http.get → JSON → Endereco
  pages/
    home_page.dart          Página 1 — cardápio
    pedido_form_page.dart   Página 2 — formulário (Stateful)
    pedidos_page.dart       Página 3 — lista em tempo real
assets/images/              banner.png, logo.png
```

## Checklist RF → onde está

| RF | Requisito | Onde mostrar |
|---|---|---|
| RF01 | Scaffold/appBar/body em todas, AppBar personalizada, TextStyle | `theme.dart` (`cantinaAppBar`), todas as páginas |
| RF02 | ≥ 2 imagens com BoxFit + ícones | `Image.asset` banner (`cover`) e logo (`contain`); `Image.network` produtos (`cover`); ícones em toda a UI |
| RF03 | Column/Row com alinhamentos, SingleChildScrollView, Stack+Positioned | `home_page.dart` → `_Banner` (Stack com 3 Positioned); scroll na Home e no formulário |
| RF04 | 3 páginas em arquivos separados, Navigator + parâmetros | Home → `PedidoFormPage(produto:)` → `PedidosPage(clienteDestaque:)` |
| RF05 | StatefulWidget + setState | `PedidoFormPage`: total recalcula ao trocar tamanho/adicionais; "Pedido de X" muda ao digitar o nome |
| RF06 | ≥ 3 TextFields com controller/label/onChanged | nome, CEP, rua, nº, bairro, cidade, observação |
| RF07 | Checkbox + grupo de Radio com enum | `CheckboxListTile` adicionais + `Checkbox` "para viagem"; `RadioGroup<Tamanho>` |
| RF08 | `add()` + `snapshots()` + StreamBuilder + loading | `_salvar()` e `PedidosPage` (`CircularProgressIndicator` no `waiting`) |
| RF09 | Recurso extra | Digitar CEP de 8 dígitos → rua/bairro/cidade preenchidos (`viacep_service.dart`) |

**Demo do ViaCEP:** CEP `01310-100` (Av. Paulista) ou o CEP de casa.
**Demo do tempo real:** abra o app em duas abas do Chrome, envie um pedido em uma — aparece na outra (critério C5).

## Plano B

Grave um vídeo curto do fluxo completo e tire prints de cada RF antes do dia, caso a internet do laboratório falhe.
