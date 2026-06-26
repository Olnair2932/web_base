#!/bin/bash
# NEXUS ESTOQUE v4.0 - O TEMPLATE DEFINITIVO (Mural + PWA + DarkMode + Imagens Locais)
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_PRODUTOS="$RAIZ_WEB/produtos.json"
INDEX_FILE="$RAIZ_WEB/index.html"

[ ! -d "$RAIZ_WEB/img" ] && mkdir -p "$RAIZ_WEB/img"
[ ! -f "$DB_PRODUTOS" ] && echo '[]' > "$DB_PRODUTOS"

if [ "$#" -ne 3 ]; then
    echo -e "\033[1;31m[ERRO]\033[0m Uso: ./nexus_estoque.sh \"Nome\" \"Preço\" \"imagem.jpg\""
    exit 1
fi

NOME=$1; PRECO=$2; IMG_INPUT=$3; ID=$(date +%s)
[[ $IMG_INPUT == http* ]] && IMG_PATH=$IMG_INPUT || IMG_PATH="img/$IMG_INPUT"

# Atualiza Banco de Dados
TMP=$(mktemp)
jq --arg id "$ID" --arg nm "$NOME" --arg pr "$PRECO" --arg im "$IMG_PATH" \
'. += [{id: $id, nome: $nm, preco: ("R$ " + $pr), img: $im}]' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

LISTA_JSON=$(cat "$DB_PRODUTOS")

# RECONSTRUÇÃO DO INDEX SUPREMO
cat << EOT > "$INDEX_FILE"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#ff69b4">
    <link rel="manifest" href="manifest.json">
    <title>Kellen do Crochê | Catálogo Oficial</title>
    <style>
        :root { --bg: #ffc0cb; --card: white; --text: #333; --header: #ff69b4; --btn: #ff1493; }
        body.dark { --bg: #1a1a1a; --card: #2d2d2d; --text: #f0f0f0; --header: #b0467a; --btn: #ff69b4; }
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; background: var(--bg); color: var(--text); padding-bottom: 120px; transition: 0.3s; overflow-x: hidden; }
        header { background: var(--header); color: white; text-align: center; padding: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .carousel-container { position: relative; max-width: 90%; margin: 15px auto; overflow: hidden; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); background: var(--card); }
        .carousel-slides { display: flex; transition: transform 0.6s ease-in-out; }
        .slide { min-width: 100%; }
        .slide img { width: 100%; height: 250px; object-fit: cover; }
        .produtos { display: flex; flex-wrap: wrap; justify-content: center; gap: 15px; padding: 15px; }
        .card { background: var(--card); width: 320px; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); padding: 15px; text-align: center; }
        .card img { width: 100%; height: 220px; object-fit: cover; border-radius: 15px; }
        .preco { font-size: 24px; color: var(--btn); font-weight: bold; margin: 12px 0; }
        button { background: var(--btn); color: white; border: none; padding: 14px; border-radius: 12px; cursor: pointer; width: 100%; font-weight: bold; }
        .btn-interacao { display: flex; gap: 8px; margin-top: 10px; }
        .like-btn { background: var(--card); color: var(--btn); border: 2px solid var(--btn); flex: 0.3; border-radius: 12px; }
        .like-btn.liked { background: var(--btn); color: white; }
        #secao-comentarios { max-width: 600px; margin: 20px auto; background: var(--card); padding: 20px; border-radius: 20px; width: 90%; box-sizing: border-box; }
        .comentario-item { border-bottom: 1px solid #eee; padding: 10px 0; font-size: 14px; text-align: left; }
        #topBtn, #shareBtn, #darkBtn { position: fixed; border: none; border-radius: 50%; cursor: pointer; z-index: 1000; color: white; width: 55px; height: 55px; display: flex; align-items: center; justify-content: center; font-size: 24px; box-shadow: 0 4px 10px rgba(0,0,0,0.2); }
        #topBtn { bottom: 20px; right: 20px; background: #ff1493; display: none; }
        #shareBtn { bottom: 85px; right: 20px; background: #4267B2; }
        #darkBtn { bottom: 150px; right: 20px; background: #333; }
    </style>
</head>
<body>
<header><h1>Kellen do Crochê</h1><p>Arte e Engenharia em cada ponto 🧶</p></header>

<div class="carousel-container"><div class="carousel-slides" id="carousel">
    <div class="slide"><img src="img/croche_real.webp" onerror="this.src='https://images.unsplash.com/photo-1621419350937-be418043685f?q=80&w=800'"></div>
    <div class="slide"><img src="https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?q=80&w=800"></div>
</div></div>

<section class="produtos" id="app"></section>

<section id="secao-comentarios">
    <h3>Mural de Clientes</h3>
    <textarea id="texto-comentario" style="width:100%; border-radius:12px; padding:10px; font-family:inherit;" rows="3" placeholder="O que achou do trabalho da Kellen?"></textarea>
    <button onclick="postarComentario()" style="margin-top:10px;">Publicar Elogio</button>
    <div id="mural-comentarios"></div>
</section>

<button id="darkBtn" onclick="toggleDark()">🌙</button>
<button id="topBtn" onclick="window.scrollTo({top: 0, behavior: 'smooth'})">↑</button>
<button id="shareBtn" onclick="compartilhar()">🔗</button>

<script>
    if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js');
    const produtos = $LISTA_JSON;
    const app = document.getElementById('app');
    let likesSalvos = JSON.parse(localStorage.getItem('kellen_likes')) || {};

    produtos.forEach(p => {
        const isLiked = likesSalvos[p.id] ? 'liked' : '';
        app.innerHTML += \`
            <div class="card">
                <img src="\${p.img}" alt="\${p.nome}" onerror="this.src='https://via.placeholder.com/300x220?text=Kellen+Croche'">
                <h3>\${p.nome}</h3>
                <div class="preco">\${p.preco}</div>
                <div class="btn-interacao">
                    <button class="like-btn \${isLiked}" onclick="toggleLike(this, '\${p.id}')">♥</button>
                    <button onclick="window.location.href='https://wa.me/5551984578173?text=Olá!%20Quero:%20\${encodeURIComponent(p.nome)}'">Comprar</button>
                </div>
            </div>\`;
    });

    function toggleDark() {
        document.body.classList.toggle('dark');
        const isDark = document.body.classList.contains('dark');
        localStorage.setItem('kellen_dark', isDark);
        document.getElementById('darkBtn').innerText = isDark ? '☀️' : '🌙';
    }
    if(localStorage.getItem('kellen_dark') === 'true') toggleDark();

    function toggleLike(btn, id) {
        btn.classList.toggle('liked');
        likesSalvos[id] = btn.classList.contains('liked');
        localStorage.setItem('kellen_likes', JSON.stringify(likesSalvos));
    }

    function postarComentario() {
        const txt = document.getElementById('texto-comentario');
        if(!txt.value.trim()) return;
        let lista = JSON.parse(localStorage.getItem('kellen_coments')) || [];
        lista.unshift(txt.value);
        localStorage.setItem('kellen_coments', JSON.stringify(lista));
        txt.value = "";
        renderComents();
    }

    function renderComents() {
        const mural = document.getElementById('mural-comentarios');
        let lista = JSON.parse(localStorage.getItem('kellen_coments')) || [];
        mural.innerHTML = lista.map(c => \`<div class="comentario-item">⭐ \${c}</div>\`).join('');
    }

    function compartilhar() {
        if (navigator.share) navigator.share({ title: 'Kellen do Crochê', url: window.location.href });
        else alert('Link copiado!');
    }

    window.onscroll = () => document.getElementById("topBtn").style.display = window.scrollY > 300 ? "flex" : "none";
    renderComents();

    let slideIdx = 0;
    setInterval(() => {
        const c = document.getElementById('carousel');
        if(c) { slideIdx = (slideIdx + 1) % 2; c.style.transform = \`translateX(-\${slideIdx * 100}%)\`; }
    }, 4000);
</script>
</body>
</html>
EOT
cd $RAIZ_WEB && ./deploy.sh
