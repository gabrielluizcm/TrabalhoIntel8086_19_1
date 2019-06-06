# Trabalho Intel 8086 - ARQ 1 19/1
Trabalho do Intel 8086 da cadeira de ARQ 1 - 19/1 contendo a implementação em ASM do programa solicitado na especificação disponível em **(../Especificacao.pdf)**.

Resumidamente, o programa consiste em exibir na tela o conteúdo de um arquivo de texto digitando periodicamente caractere a caractere, sendo que a periodicidade é definida dentro do próprio arquivo em tags na forma **#xx**, onde **xx** é um número decimal entre **01 e 99** ticks.

## Funções Básicas
As funções básicas usadas no programa disponíveis em **(../FuncoesBasicas/*)** foram cedidas pelo professor e desempenham:
- **atoi**: Converte uma string em um número de 16 bits
- **printf_s**: Escreve o conteúdo de uma string na tela
- **ReadString**: Lê uma string do teclado

As funções ainda para serem desenvolvidas serão descritas gradativamente.

### Aviso
Qualquer cópia do código, seja parcial ou total, é expressamente proibida, **exceto nos trechos cedidos pelo professor**, tendo em vista a anulação do trabalho para todas as partes caso constatado plágio.