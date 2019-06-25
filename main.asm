.model small
.stack

    CR  equ 13
    LF  equ 10

.data
    Periodicidade   dw  1
    TempPeriod      dw  0
    TempoInicial    dw  0
    NovaLinhaStr    db  CR, LF, 0
    NomeArquivo     db  21 DUP (0)
    HandleArquivo   dw  0
    LeituraArquivo  db  0
    Identificacao   db  'Gabriel Luiz Carpes Maria - 00281952', CR, LF, 0
    PerguntaNome    db  'Digite o nome do arquivo (max 20): ', 0
    FimNormal   db  'O programa foi encerrado corretamente por decisao do usuario.', CR, LF, 0
    ErroAoAbrir db  'Falha ao abrir - arquivo nao encontrado!', CR, LF, 0
    ErroDeTag   db  'Erro no conteudo do arquivo', CR, LF, 0
.code
.startup
    call limpaTela
    lea bx, Identificacao
    call printf_s

    loopArquivo:
    call printaPergunta
    call ReadString
    call stringFoiVazia
    jmpReinicio:    ;jmp se apertar 'r'
    call abreArquivo
    jnc conseguiuAbrir
    call erroDeAbertura
    jmp loopArquivo

    conseguiuAbrir:
    mov HandleArquivo, ax
    call limpaTela
    mov Periodicidade, 1

    loopLeitura:
    call getTime
    mov TempoInicial, dx
    call leProxChar
    cmp ax, 0   ;verifica se e o fim do arquivo
    jnz naoEEOF
    call fechaArquivo
    call limpaTela
    jmp loopArquivo

    naoEEOF:    ;se nao for continua
    cmp LeituraArquivo, 35
    jnz loopDeEspera    ;se não for '#' entra em espera
    ;mudanca de periodicidade
    mov TempPeriod, 0
    call leProxChar
    cmp LeituraArquivo, 48  ;é número?
    jl erroNaTag
    cmp LeituraArquivo, 57
    jg erroNaTag
    mov ax, 0
    mov al, LeituraArquivo
    sub ax, 48  ;tira o "offset" da tabela ascii
    mov cx, 10  ;coloca como dezena
    mul ax
    mov TempPeriod, ax
    call leProxChar
    cmp LeituraArquivo, 48  ;verifica e soma a unidade
    jl erroNaTag
    cmp LeituraArquivo, 57
    jg erroNaTag
    mov ax, 0
    mov ax, TempPeriod
    add al, LeituraArquivo
    sub ax, 48
    mov Periodicidade, ax
    mov TempPeriod, 0
    jmp loopLeitura

    erroNaTag:
    call limpaTela
    lea bx, ErroDeTag
    call printf_s
    call ReadString
    jmp loopArquivo

    loopDeEspera:
    call getTime
    mov ax, dx
    sub ax, TempoInicial
    js  virouTempo
    cmp ax, Periodicidade
    jg podePrintar
    jmp loopDeEspera

    podePrintar:
    call putChar
    call kbHit
    cmp al, 0
    je loopLeitura

    ;caso haja tecla:
    call getChar

    cmp al, 114 ;confere o 'r'
    je reinicia
    cmp al, 82
    je reinicia

    cmp al, 110 ;confere o 'n'
    je novoArquivo
    cmp al, 78
    je novoArquivo

    cmp al, 27  ;confere o ESC
    je escape

    jmp loopLeitura

    reinicia:
    call fechaArquivo
    call limpaTela
    jmp jmpReinicio

    novoArquivo:
    call fechaArquivo
    call limpaTela
    jmp loopArquivo

    escape:
    call fechaArquivo
    call limpaTela
    lea bx, FimNormal
    call printf_s
    .exit 0

    virouTempo: ;caso o tempo atual seja menor que o inicial
    mov TempoInicial, 0
    call getTime
    mov dx, Periodicidade
    jg podePrintar
.exit

printaPergunta proc near
    lea bx, PerguntaNome
    call printf_s
    lea bx, NomeArquivo
    mov cx, 20
    ret
printaPergunta endp

;verifica se o nome do arquivo e vazio -> somente ENTER foi teclado
stringFoiVazia proc near
    mov al, NomeArquivo[0]
    cmp al, 0
    jnz fazNada
    call fechaArquivo
    call novaLinha
    lea bx, FimNormal
    call printf_s
    .exit 0
    fazNada:
    ret
stringFoiVazia endp

limpaTela proc near
    mov ax, 3
    int 10h
    ret
limpaTela endp

novaLinha proc near
    lea bx, novaLinhaStr
    call printf_s
    ret
novaLinha endp

abreArquivo proc near
    lea dx, NomeArquivo
    mov al, 0
    mov ah, 3dh
    int 21h
    ret
abreArquivo endp

fechaArquivo proc near
    lea bx, NomeArquivo
    mov ah, 3eh
    int 21h
    ret
fechaArquivo endp

erroDeAbertura proc near
    call novaLinha
    lea bx, ErroAoAbrir
    call printf_s
    ret
erroDeAbertura endp

getTime proc near
    mov ah, 0
    int 1ah
    ret
getTime endp

leProxChar proc near
    mov ah, 3fh
    mov bx, HandleArquivo
    mov cx, 1
    lea dx, LeituraArquivo
    int 21h
    ret
leProxChar endp

putChar proc near
    mov dl, LeituraArquivo
    mov ah, 2
    int 21h
    ret
putChar endp

getChar proc near
    mov ah, 8h
    int 21H
    ret
getChar endp

kbHit proc near
    mov ah, 0bh
    int 21H
    ret
kbHit endp

;######### TRECHO DE CODIGO NAO-AUTORAL, CEDIDO PELO PROFESSOR #################################
    ;--------------------------------------------------------------------
    ;Funcao: Escrever um string na tela
    ;
    ;void printf_s(char *s -> BX) {
    ;	While (*s!='\0') {
    ;		putchar(*s)
    ; 		++s;
    ;	}
    ;}
    ;--------------------------------------------------------------------
    printf_s	proc	near

    ;	While (*s!='\0') {
        mov		dl,[bx]
        cmp		dl,0
        je		ps_1

    ;		putchar(*s)
        push	bx
        mov		ah,2
        int		21H
        pop		bx

    ;		++s;
        inc		bx
            
    ;	}
        jmp		printf_s
            
    ps_1:
        ret
        
    printf_s	endp

    ;--------------------------------------------------------------------
    ;Funcao: Le um string do teclado
    ;Entra: (S) -> DS:BX -> Ponteiro para o string
    ;	    (M) -> CX -> numero maximo de caracteres aceitos
    ;Algoritmo:
    ;	Pos = 0
    ;	while(1) {
    ;		al = Int21(7)	// Espera pelo teclado
    ;		if (al==CR) {
    ;			*S = '\0'
    ;			return
    ;		}
    ;		if (al==BS) {
    ;			if (Pos==0) continue;
    ;			Print (BS, SPACE, BS)	// Coloca 3 caracteres na tela
    ;			--S
    ;			++M
    ;			--Pos
    ;		}
    ;		if (M==0) continue
    ;		if (al>=SPACE) {
    ;			*S = al
    ;			++S
    ;			--M
    ;			++Pos
    ;			Int21 (s, AL)	// Coloca AL na tela
    ;		}
    ;	}
    ;--------------------------------------------------------------------
    ReadString	proc	near

            ;Pos = 0
            mov		dx,0

    RDSTR_1:
            ;while(1) {
            ;	al = Int21(7)		// Espera pelo teclado
            mov		ah,7
            int		21H

            ;	if (al==CR) {
            cmp		al,0DH
            jne		RDSTR_A

            ;		*S = '\0'
            mov		byte ptr[bx],0
            ;		return
            ret
            ;	}

    RDSTR_A:
            ;	if (al==BS) {
            cmp		al,08H
            jne		RDSTR_B

            ;		if (Pos==0) continue;
            cmp		dx,0
            jz		RDSTR_1

            ;		Print (BS, SPACE, BS)
            push	dx
            
            mov		dl,08H
            mov		ah,2
            int		21H
            
            mov		dl,' '
            mov		ah,2
            int		21H
            
            mov		dl,08H
            mov		ah,2
            int		21H
            
            pop		dx

            ;		--s
            dec		bx
            ;		++M
            inc		cx
            ;		--Pos
            dec		dx
            
            ;	}
            jmp		RDSTR_1

    RDSTR_B:
            ;	if (M==0) continue
            cmp		cx,0
            je		RDSTR_1

            ;	if (al>=SPACE) {
            cmp		al,' '
            jl		RDSTR_1

            ;		*S = al
            mov		[bx],al

            ;		++S
            inc		bx
            ;		--M
            dec		cx
            ;		++Pos
            inc		dx

            ;		Int21 (s, AL)
            push	dx
            mov		dl,al
            mov		ah,2
            int		21H
            pop		dx

            ;	}
            ;}
            jmp		RDSTR_1

    ReadString	endp

;######### FIM DO TRECHO DE CODIGO NAO-AUTORAL #################################################

end
