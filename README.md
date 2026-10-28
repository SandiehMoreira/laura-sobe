# Laura Sobe! 🚀

Laura Pula 2: jogo de pulo para subir, feito para a Laura. A Laura pula de plataforma em plataforma
e vai subindo da cidade até as galáxias. Pontuação = altura em metros, com recorde.

- Fases: cidade (0 m) → céu (150 m) → espaço (400 m) → constelações (700 m) → galáxias (1000 m)
- Plataformas que andam e que quebram; mola (super pulo), foguete e estrelinhas
- Celular: segure o dedo para onde a Laura deve ir. PC: ← → ou A / D. M = som.

Tudo num `index.html` (canvas, sem bibliotecas). Poses da Laura em `img/` (as mesmas do Laura Pula).

## Gerar os instaladores
- Windows: `"%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" windows\LauraSobe.iss` → `build/LauraSobe-Setup.exe`
- Android: `sh android/gerar-apk.sh` → `build/LauraSobe.apk` (guarde `android/laura.keystore` e `keystore.properties`, fora do git)

Jogue em https://sandieh.online/laura-sobe/
