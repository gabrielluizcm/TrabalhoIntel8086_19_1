.model small
.stack

    CR  equ 13
    LF  equ 10

.data
    Periodicidade   db  1
    TempoInicial    dw  0
    NovaLinhaStr   db  CR, LF, 0
    NomeArquivo db  100 dup (?)
    LeituraArquivo  db  0
    Identificacao   db  'Gabriel Luiz Carpes Maria - 00281952', CR, LF, 0
    PerguntaNome    db  'Digite o nome do arquivo (max 20): ', 0
    FimNormal   db  'O programa foi encerrado corretamente por decisao do usuario.', CR, LF, 0
    ErroAoAbrir db  'Falha ao abrir - arquivo nao encontrado!', CR, LF, 0
    ErroDeTag   db  'Erro no conteúdo do arquivo', CR, LF, 0
.code
.startup
    call limpaTela
    lea bx, Identificacao
    call printf_s

    loopArquivo:
    call printaPergunta
    call ReadString
    call stringFoiVazia
    call abreArquivo
    jnc conseguiuAbrir
    call erroDeAbertura
    jmp loopArquivo

    conseguiuAbrir:
    call limpaTela
    mov Periodicidade, 1
    call getTime
    mov TempoInicial, dx
    call leProxChar
    cmp ax, 0   ;verifica se é o fim do arquivo
    jnz naoEEOF
    call fechaArquivo
    call limpaTela
    jmp loopArquivo

    naoEEOF:    ;se não for continua
    cmp LeituraArquivo, 35
    jnz loopDeEspera    ;se não for '#' entra em espera
    cmp al, 0
    jz mudaPeriodicidade
    lea bx, ErroDeTag
    call printf_s
    call ReadString
    call limpaTela
    jmp loopArquivo

    loopDeEspera:

    mudaPeriodicidade:
.exit

printaPergunta proc near
    lea bx, PerguntaNome
    call printf_s
    lea bx, NomeArquivo
    mov cx, 20
    ret
printaPergunta endp

;verifica se o nome do arquivo é vazio -> somente ENTER foi teclado
stringFoiVazia proc near
    mov al, NomeArquivo[0]
    cmp al, 0
    jnz fazNada
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

leProxChar proc near
    mov ah, 3fh
    lea bx, NomeArquivo
    mov cx, 1
    lea dx, LeituraArquivo
    int 21h
    ret
leProxChar endp

getTime proc near
    mov ah, 0
    int 1ah
    ret
getTime endp


;######### TRECHO DE CÓDIGO NÃO-AUTORAL, CEDIDO PELO PROFESSOR #################################
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

    ;--------------------------------------------------------------------
    ;Funcao:Converte um ASCII-DECIMAL para HEXA
    ;Entra: (S) -> DS:BX -> Ponteiro para o string de origem
    ;Sai:	(A) -> AX -> Valor "Hex" resultante
    ;Algoritmo:
    ;	A = 0;
    ;	while (*S!='\0') {
    ;		A = 10 * A + (*S - '0')
    ;		++S;
    ;	}
    ;	return
    ;--------------------------------------------------------------------
    atoi	proc near

            ; A = 0;
            mov		ax,0
            
    atoi_2:
            ; while (*S!='\0') {
            cmp		byte ptr[bx], 0
            jz		atoi_1

            ; 	A = 10 * A
            mov		cx,10
            mul		cx

            ; 	A = A + *S
            mov		ch,0
            mov		cl,[bx]
            add		ax,cx

            ; 	A = A - '0'
            sub		ax,'0'

            ; 	++S
            inc		bx
            
            ;}
            jmp		atoi_2

    atoi_1:
            ; return
            ret

    atoi	endp

;######### FIM DO TRECHO DE CÓDIGO NÃO-AUTORAL #################################################

end