#!/bin/bash
# NEXUS ESTOQUE v1.0 - Automação de Catálogo
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_PRODUTOS="$RAIZ_WEB/produtos.json"
INDEX_FILE="$RAIZ_WEB/index.html"

# Inicializa o JSON se não existir
if [ ! -f "$DB_PRODUTOS" ]; then
    echo '[]' > "$DB_PRODUTOS"
fi

# Verifica argumentos
if [ "$#" -ne 3 ]; then
    echo -e "\033[1;31m[ERRO]\033[0m Uso: ./nexus_estoque.sh \"Nome\" \"Preço\" \"URL_Imagem\""
    exit 1
fi

NOME=$1
PRECO=$2
IMG=$3
ID=$(date +%s)

echo -e "\033[1;35m[NEXUS]:\033[0m Adicionando '$NOME' ao sistema..."

# 1. Adiciona ao banco de dados JSON usando jq
TMP=$(mktemp)
jq --arg id "$ID" --arg nm "$NOME" --arg pr "$PRECO" --arg im "$IMG" \
'. += [{id: $id, nome: $nm, preco: ("R$ " + $pr), img: $im}]' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

# 2. Reconstroi o index.html com o novo banco de dados
LISTA_JSON=$(cat "$DB_PRODUTOS")

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
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; background: #ffc0cb; padding-bottom: 120px; }
        header { background: #ff69b4; color: white; text-align: center; padding: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .carousel-container { position: relative; max-width: 90%; margin: 15px auto; overflow: hidden; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); background: white; }
        .carousel-slides { display: flex; transition: transform 0.6s ease-in-out; }
        .slide { min-width: 100%; }
        .slide img { width: 100%; height: 250px; object-fit: cover; }
        .produtos { display: flex; flex-wrap: wrap; justify-content: center; gap: 15px; padding: 15px; }
        .card { background: white; width: 320px; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); padding: 15px; text-align: center; }
        .card img { width: 100%; height: 220px; object-fit: cover; border-radius: 15px; }
        .preco { font-size: 24px; color: #ff69b4; font-weight: bold; margin: 12px 0; }
        button { background: #ff1493; color: white; border: none; padding: 14px; border-radius: 12px; cursor: pointer; width: 100%; font-weight: bold; }
        #topBtn, #shareBtn { position: fixed; right: 20px; border: none; border-radius: 50%; cursor: pointer; z-index: 1000; color: white; width: 55px; height: 55px; display: flex; align-items: center; justify-content: center; font-size: 24px; box-shadow: 0 4px 10px rgba(0,0,0,0.2); }
        #topBtn { bottom: 20px; background: #ff1493; display: none; }
        #shareBtn { bottom: 85px; background: #4267B2; }
        .btn-interacao { display: flex; gap: 8px; margin-top: 10px; }
        .like-btn { background: #fff; color: #ff1493; border: 2px solid #ff1493; flex: 0.3; border-radius: 12px; }
        .like-btn.liked { background: #ff1493; color: #fff; }
        #secao-comentarios { max-width: 600px; margin: 20px auto; background: white; padding: 20px; border-radius: 20px; width: 90%; }
        .comentario-item { border-bottom: 1px solid #eee; padding: 10px 0; font-size: 14px; color: #444; }
    </style>
</head>
<body>
<header>
    <h1>Kellen do Crochê</h1>
    <p>Arte e Engenharia em cada ponto 🧶</p>
</header>

<div class="carousel-container">
    <div class="carousel-slides" id="carousel">
        <div class="slide"><img src="https://images.unsplash.com/photo-1621419350937-be418043685f?q=80&w=800" alt="Bolsa"></div>
        <div class="slide"><img src="https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?q=80&w=800" alt="Trilho"></div>
    </div>
</div>

<section class="produtos" id="app"></section>

<section id="secao-comentarios">
    <h3>Mural de Clientes</h3>
    <textarea id="texto-comentario" style="width:100%; border-radius:12px; padding:10px; border:1px solid #ddd;" rows="3" placeholder="Deixe um elogio..."></textarea>
    <button onclick="postarComentario()" style="margin-top:10px;">Publicar</button>
    <div id="mural-comentarios"></div>
</section>

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
                <img src="\${p.img}" alt="\${p.nome}">
                <h3>\${p.nome}</h3>
                <div class="preco">\${p.preco}</div>
                <div class="btn-interacao">
                    <button class="like-btn \${isLiked}" onclick="toggleLike(this, '\${p.id}')">♥</button>
                    <button onclick="window.location.href='https://wa.me/5551984578173?text=Olá!%20Quero:%20\${encodeURIComponent(p.nome)}'">Comprar</button>
                </div>
            </div>\`;
    });

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

# 3. Executa o Deploy Automático
echo -e "\033[1;32m[SUCESSO]:\033[0m Produto '$NOME' injetado. Iniciando Deploy..."
cd $RAIZ_WEB && ./deploy.sh
