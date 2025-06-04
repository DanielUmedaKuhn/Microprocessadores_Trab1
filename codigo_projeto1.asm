ORG 0000H         ; Início do programa

; Definições de variáveis e registradores
TIME_DELAY EQU 30H ; Define TIME_DELAY no endereço 30H (RAM interna)
MOV P1, #0FFH      ; Inicializa a porta P1 (Display de 7 segmentos)
MOV DPTR, #seg_codes ; Aponta para a tabela de códigos de segmentos
MOV R0, #00H       ; Inicializa o contador para 0 a 9
MOV TIME_DELAY, #00H ; Inicializa TIME_DELAY com zero

; Início do loop principal
main:
    ACALL verifica_botoes ; Verifica continuamente os botões
    MOV A, TIME_DELAY
    CJNE A, #00H, continua ; Se TIME_DELAY não for zero, continua
    MOV P1, #0FFH          ; Mantém o display desligado
    SJMP main              ; Continua o loop principal

continua:
    ; Chama a sub-rotina de exibição
    ACALL display_loop     ; Inicia a contagem no display
    SJMP main              ; Volta para o loop principal

; Sub-rotina de loop de exibição
display_loop:
    ; Loop de contagem de 0 a 9
display_loop_interno:
    ACALL verifica_botoes  ; Verifica os botões durante a contagem
    MOV A, TIME_DELAY
    CJNE A, #00H, continua_contagem ; Se TIME_DELAY não for zero, continua
    RET                     ; Se TIME_DELAY for zero, sai do loop de exibição

continua_contagem:
    ACALL display_number   ; Exibe o número no display
    ACALL aplica_delay     ; Executa o delay
    ACALL incrementa_cont  ; Incrementa o contador de números
    SJMP display_loop_interno ; Continua a contagem
    RET

; Sub-rotina para verificar e configurar o delay baseado nos botões
verifica_botoes:
    JNB P2.0, sw0_ativo
    JNB P2.1, sw1_ativo
    RET                     ; Retorna se nenhum botão foi pressionado

sw0_ativo:
    MOV TIME_DELAY, #5     ; Define delay de 1 segundo (20 x 50ms)
    RET                     ; Retorna ao loop

sw1_ativo:
    MOV TIME_DELAY, #20      ; Define delay de 0,25 segundos (5 x 50ms)
    RET                     ; Retorna ao loop

; Sub-rotina para exibir um número no display de 7 segmentos
display_number:
    MOV A, R0               ; Carrega o valor do contador
    MOVC A, @A+DPTR         ; Carrega o padrão correspondente da tabela
    MOV P1, A               ; Exibe o padrão no display
    RET

; Sub-rotina para aplicar o delay usando Timer 0
aplica_delay:
    MOV R2, TIME_DELAY      ; Carrega o tempo de delay (multiplicador)
delay_loop:
    MOV TMOD, #01H          ; Configura Timer 0 no modo 1 (16 bits)
    MOV TH0, #3CH           ; Carrega TH0 para 50ms
    MOV TL0, #0B0H          ; Carrega TL0 para 50ms
    SETB TR0                ; Inicia o Timer 0
esperar_delay:
    JNB TF0, esperar_delay  ; Aguarda o transbordo do Timer 0
    CLR TR0                 ; Para o Timer 0
    CLR TF0                 ; Limpa a flag TF0
    DJNZ R2, delay_loop     ; Decrementa R2 e repete até zero
    RET

; Sub-rotina para incrementar a contagem dos números
incrementa_cont:
    INC R0                  ; Incrementa o contador
    CJNE R0, #0AH, retorna  ; Se R0 != 10, continua
    MOV R0, #00H            ; Reinicia o contador se chegar a 10
retorna:
    RET

; Tabela de códigos para os dígitos de 0 a 9
seg_codes:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H

END
