module dialogue;
import std;
import raylib;
import config;
import world;

struct Dialog {
    string[] lines;
    int dialog_count = 0;
}

Dialog[TileType] NPC_DIALOGUES;

static this() {
    NPC_DIALOGUES[TileType.NPC_GHOST_GENTLEMAN] = Dialog([
        "Os vivos correm tanto... e esquecem de sentir. Eu, ao menos, tenho tempo.",
        "Você lê? Ah... então ainda há esperança nesse mundo vazio.",
        "Às vezes penso que fui escrito por alguém... e esquecido no fim do capítulo.",
        "Não me tema. Eu só procuro um final que ainda me faça chorar.",
    ]);

    NPC_DIALOGUES[TileType.NPC_POETIC_KNIGHT] = Dialog([
        "Mesmo em meio à batalha, um bom verso pode curar a alma.",
        "O aço é forte... mas um poema bem escrito corta mais fundo.",
        "Já lutei por reis, agora luto por rimas.",
        "Já ouvi o som do aço, mas nenhum som é tão belo quanto o de um poema bem lido.",
    ]);

    NPC_DIALOGUES[TileType.NPC_GREEN_GUY] = Dialog([
        "O livro diz pra acreditar em mim mesmo... mas nem eu confio em mim.",
        "Capítulo cinco: 'Você é a solução dos seus problemas'. Acho que sou um problema mal escrito.",
        "Três livros de autoajuda depois... e continuo me ajudando a me afundar.",
        "Este livro promete transformar minha vida. Pena que não ensina a começar.",
    ]);

    NPC_DIALOGUES[TileType.NPC_PUMPKIN_GUY] = Dialog([
        "Você viu um livro de culinária por aí? Prometo que não é pra nada... suspeito.",
        "Dizem que cozinhar é uma arte... e eu sou a obra-prima mais confusa da cozinha.",
        "Preciso daquele livro! O 'Segredos da Colheita' tem uma receita que pode mudar minha vida - ou me derreter.",
        "Sabe o que é estranho? Todo mundo foge quando digo que vou cozinhar algo 'de corpo e alma'.",
        "Achei um livro ontem... mas era de feitiços. Agora minha sopa brilha no escuro.",
        "Prometo que, se achar o livro, faço uma torta que você nunca vai esquecer. Literalmente.",
        "Cozinhar é uma questão de alma... e, no meu caso, de sementes também.",
    ]);

    NPC_DIALOGUES[TileType.NPC_LAMP_HEAD] = Dialog([
        "Se eu estudar demais... será que acabo queimando o cérebro ou a lâmpada?",
        "O conhecimento ilumina... mas, às vezes, dói nos olhos.",
        "Dizem que estudar é acender uma luz na mente. No meu caso, é só recarregar a cabeça.",
        "Queria entender por que, quanto mais aprendo, mais escuro o mundo parece.",
    ]);

    NPC_DIALOGUES[TileType.NPC_SITTING_GUY] = Dialog([
        "\"Esses heróis morreram por ideais... E hoje mal lembramos os nomes deles.\"",
        "História é o eco dos erros que a gente insiste em repetir.",
        "Quanto mais leio sobre o passado, mais entendo por que o futuro se esconde.",
        "Alguns chamam de história. Eu chamo de lembrança que o tempo não conseguiu apagar.",
    ]);

    NPC_DIALOGUES[TileType.NPC_RECEPTIONIST] = Dialog([
        "Posso de ajudar?",
        "Bem-vindo! Precisa de ajuda para encontrar algo?",
        "Alguns dizem que já encontrei livros que nem existiam… mas não conte a ninguém.",
        "Cuidado com os livros mágicos, eles às vezes… andam sozinhos.",
    ]);

    NPC_DIALOGUES[TileType.NPC_SLEEPY_ALIEN] = Dialog([
        "Não estou dormindo, só estou descansando os olhos.",
    ]);
}
