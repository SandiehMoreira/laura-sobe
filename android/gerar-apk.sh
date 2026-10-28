#!/bin/sh
# Gera build/LauraSobe.apk sem Gradle (só build-tools 34 + platform android-34 + JDK 17).
# Uso (Git Bash, na pasta do projeto): sh android/gerar-apk.sh
set -e
VERSAO_NOME=${VERSAO_NOME:-1.0.0}
VERSAO_COD=${VERSAO_COD:-1}

SDK="${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}"
BT="$SDK/build-tools/34.0.0"
JAR="$SDK/platforms/android-34/android.jar"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
A="$RAIZ/android"
B="$RAIZ/build/android"

rm -rf "$B" && mkdir -p "$B/assets/www/img" "$B/assets/www/icone" "$B/res" "$B/classes" "$B/dex"

# jogo -> assets
cp "$RAIZ/index.html" "$B/assets/www/"
cp "$RAIZ"/img/*.png "$B/assets/www/img/"
cp "$RAIZ/icone/icone-192.png" "$RAIZ/icone/apple-touch-icon.png" "$B/assets/www/icone/"
cp -r "$RAIZ"/icone/android/mipmap-* "$B/res/"

"$BT/aapt2" compile --dir "$B/res" -o "$B/res.zip"
"$BT/aapt2" link -o "$B/base.apk" -I "$JAR" --manifest "$A/AndroidManifest.xml" -A "$B/assets" \
  --min-sdk-version 21 --target-sdk-version 34 --version-code "$VERSAO_COD" --version-name "$VERSAO_NOME" "$B/res.zip"

javac -source 8 -target 8 -nowarn -Xlint:-options -classpath "$JAR" -d "$B/classes" "$A"/src/online/sandieh/laurasobe/*.java
"$BT/d8.bat" --release --lib "$JAR" --min-api 21 --output "$B/dex" $(find "$B/classes" -name '*.class')

python -I -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1],'a'); z.write(sys.argv[2],'classes.dex'); z.close()" "$B/base.apk" "$B/dex/classes.dex"
"$BT/zipalign" -p -f 4 "$B/base.apk" "$B/alinhado.apk"

# chave de assinatura: guardar android/laura.keystore e android/keystore.properties (sem eles não dá para atualizar o app)
KS="$A/laura.keystore"; PROPS="$A/keystore.properties"
if [ ! -f "$KS" ]; then
  SENHA=$(python -I -c "import secrets; print(secrets.token_urlsafe(18))")
  keytool -genkeypair -keystore "$KS" -alias laura -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass "$SENHA" -keypass "$SENHA" -dname "CN=Sandieh Moreira, O=SanMobile, C=BR" >/dev/null
  printf 'senha=%s\n' "$SENHA" > "$PROPS"
fi
SENHA=$(sed -n 's/^senha=//p' "$PROPS")
"$BT/apksigner.bat" sign --ks "$KS" --ks-key-alias laura --ks-pass "pass:$SENHA" --key-pass "pass:$SENHA" \
  --out "$RAIZ/build/LauraSobe.apk" "$B/alinhado.apk"
"$BT/apksigner.bat" verify "$RAIZ/build/LauraSobe.apk"
echo "APK pronto: build/LauraSobe.apk"
