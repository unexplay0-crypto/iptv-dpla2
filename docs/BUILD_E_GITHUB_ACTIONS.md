# Build e GitHub Actions

## Workflow (`.github/workflows/build.yml`)

Executa em `ubuntu-latest` a cada push em `main`/`master` ou manualmente
(`workflow_dispatch`):

1. Checkout do repositório
2. Instala **Java 17 (Temurin)** (requerido pelo AGP 8.x)
3. Instala **Flutter stable** (`subosito/flutter-action`, com cache)
4. `flutter create --platforms=android .` — regenera arquivos de scaffolding
   ausentes (ex.: wrapper Gradle) **sem sobrescrever** os arquivos existentes
5. `flutter pub get`
6. `dart format` (aviso, não bloqueia)
7. `flutter analyze --no-fatal-infos`
8. `flutter test`
9. `flutter build apk --debug`
10. `flutter build apk --release`
11. `flutter build appbundle` (AAB)
12. Upload dos 3 artefatos (`apk-debug`, `apk-release`, `app-bundle`)

## Assinatura de release

No workflow atual, o APK/AAB de release é assinado com a **chave de debug**
(para gerar artefato instalável no CI sem configurar segredos). Para publicar
na Play Store:

1. Crie um keystore (`keytool -genkey -v -keystore upload-keystore.jks ...`).
2. No GitHub, adicione **Secrets**: `KEYSTORE_JKS` (base64 do arquivo),
   `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.
3. Adicione um step no workflow para decodificar o keystore e configure
   `android/app/build.gradle` com `signingConfigs.release` lendo
   `key.properties`. Nunca commite o `.jks` ou senhas no repositório.

## Alterando applicationId / pacote

O `applicationId` atual é `com.iptvstreamer.app`. Para mudar:
1. Altere `namespace` e `applicationId` em `android/app/build.gradle`.
2. Mova `MainActivity.kt` para o novo pacote e atualize o `package` no topo.
3. (Opcional) Use `flutter create --org <novo.org> --project-name iptv_streamer --platforms=android .` para regenerar.

## Requisitos

- Flutter >= 3.22 (stable), Dart >= 3.4
- Java 17
- Android SDK (compileSdk 34, minSdk 23, targetSdk 34)
- Android TV: dispositivo com Android TV 9+ (API 28+) recomendado; o app
  instala em versões anteriores mas o layout TV foi otimizado para 9+.
