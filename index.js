console.log("Sistema Nexus v8.0 Ativo");
fetch('config.json').then(r => r.json()).then(d => console.log(d));
