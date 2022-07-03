
.def Contador = r9 ; contador padrao das configuracoes para nao repetir codigo

.equ ValvulaSaida = PB0	; Saida  (LED)
.equ ValvulaEntrada = PB1
.equ Motor = PB2 ; Saida (Atuador)
.equ EstadoMolho = pb3	
.equ NivelAgua = pb4
.equ CentrifugaSaida = pb5
.equ SensorVazio = pc1	; Entrada  (button)	
.equ SensorCheio = pc2	; Entrada  (button)	
.equ BotaoMais = pc3	; Entrada  (button)	
.equ BotaoMenos = pc4	; Entrada  (button)	
.equ BotaoConfirm = pc5	; Entrada  (button)	
.equ LCDisplay = PORTD

; Memórias que salvam os dados da máquina de lavar

.equ Agitar1 = 0x130
.equ Agitar2 = 0x132
.equ Molho1 = 0x134
.equ Molho2 = 0x136
.equ Centrifuga = 0x138
.org 0x00 ; linha 0

rjmp Inicio ; pula para o inicio

.include "biblioteca.inc" ; inclui a biblioteca do LCD padrao

Inicio:
	ldi r16, 0b00111111 ; configurando entradas e saídas
	out ddrb, r16 
	ldi r16, 0
	out ddrc, r16 ; ativar pull up nas entradas   
	ldi r16, 255
	out portc, r16

	out DDRD, r16 ; mostrar a mensagem inicial por 5 segundos
	clr r16
	clr Contador

	rcall lcd_init ; inicia o lcd
	rcall lcd_clear ; limpar o lcd
	rcall MensagemBemVindo ; mensagem de bem vindo

	ldi delay_time, 5  ; define tempo
	rcall delay_seconds ; chama rotina de tempo

Config_Sistema:
	rcall lcd_clear ; limpa o lcd
	rcall MensagemPadraoConfig ; mostra a mensagem padrão de configuração
	rcall Config_Agitar1
	rcall Config_Agitar2
	rcall Config_Molho1
	rcall Config_Molho2
	rcall Config_Centrifuga

Loop: 
	call ligarSistema
	call Etapa_1
	call Etapa_2

ligarSistema:
	ldi delay_time, 1
	rcall delay_seconds	; Chama rotina de atraso
	rcall Encher
	ret

Etapa_1:	  
	rcall Verificar_Maximo
	lds delay_time, Agitar1
	rcall delay_seconds	; Chama rotina de atraso
	cbi portb, Motor
	rcall Mensagem_Molho
	sbi portb, EstadoMolho
	lds delay_time, Molho1
	rcall delay_seconds	; Chama rotina de atraso
	rcall Esvaziar
	rcall Verificar_Minimo
	rcall Encher
    ret

Etapa_2:
	rcall Verificar_Maximo
	lds delay_time, Agitar2
	rcall delay_seconds	; Chama rotina de atraso
	cbi portb, Motor
	rcall Mensagem_Molho
	sbi portb, EstadoMolho
	lds delay_time, Molho2
	rcall delay_seconds	; Chama rotina de atraso
	rcall Esvaziar
	rcall Verificar_Minimo
	rcall Centrifugar 
    ret

Verificar_Minimo:
	sbic pinc, SensorVazio ; espera a agua esvaziar
	rjmp Verificar_Minimo
	ret

Verificar_Maximo:
	sbic pinc, SensorCheio ; espera a agua esvaziar
	rjmp Verificar_Maximo
	sbi portb, NivelAgua ; Nivel da agua alto
	cbi portb, ValvulaEntrada
	rcall Mensagem_Agitando
	sbi portb, Motor
	ret

Encher:
	rcall Mensagem_Enchendo
	sbi portb, ValvulaSaida ; impede a saida de agua
	sbi portb, ValvulaEntrada ; Enche de �gua a m�quina
	ret

Esvaziar:
	cbi portb, EstadoMolho
	rcall Mensagem_Esvaziando
	cbi portb, ValvulaSaida ; Abre a valvula para esvaziar
	cbi portb, NivelAgua
	ret

Centrifugar:
	rcall Mensagem_Centrifuga
	sbi portb, CentrifugaSaida
	lds delay_time, Centrifuga
	rcall delay_seconds	; Chama rotina de atraso
	rcall Desligar
	ret

Desligar:
	ldi r16, 0
	out portb, r16
	clr r16
	clr Contador
	sts Agitar1, Contador
	sts Agitar2, Contador
	sts Molho1, Contador
	sts Molho2, Contador
	rcall lcd_clear
	rcall Final_Program
	ldi delay_time, 1
	rcall delay_seconds	; Chama rotina de atraso
	rcall lcd_clear
	rcall MensagemBemVindo
	ret

; =========================== Mensagens do LCD  =========================== ;

 MensagemBemVindo:
	ldi lcd_col, 2
    rcall lcd_lin0_col
	ldi lcd_caracter, 'S'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'J'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter

	ldi lcd_col, 2
    rcall lcd_lin1_col
	ldi lcd_caracter, 'B'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'M'
	rcall lcd_write_caracter
	ldi lcd_caracter, '-'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'V'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'D'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, '('
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, ')'
	rcall lcd_write_caracter

	ret

MensagemPadraoConfig: ; mensagem presente em todas as configuracoes
	ldi lcd_col, 0
	rcall lcd_lin0_col

	ldi lcd_caracter, 'C'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'F'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'G'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	ldi lcd_caracter, 'T'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'M'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'P'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'

	rcall lcd_write_caracter
	ret


Config_Agitar1:
	clr Contador
	ldi lcd_col, 0
	rcall lcd_lin1_col

	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'G'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'T'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'R'

	rcall lcd_write_caracter
	ldi lcd_number, 1
	rcall lcd_write_number
	ldi lcd_caracter, ':'
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	rcall lcd_write_caracter
	rcall Mostrador_Config
	rcall Config_Sistema_Calc
	sts Agitar1, Contador ; Guarda valor tempo resfriamento
	clr Contador
	rcall Mostrador_Config
	ret

Config_Agitar2:
	clr Contador
	ldi lcd_col, 0
	rcall lcd_lin1_col
	
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'G'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'T'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'R'

	ldi lcd_number, 2
	rcall lcd_write_number
	ldi lcd_caracter, ':'
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	rcall lcd_write_caracter
	rcall Mostrador_Config
	rcall Config_Sistema_Calc
	sts Agitar2, Contador ; Guarda valor tempo resfriamento
	clr Contador
	rcall Mostrador_Config
	ret

Config_Molho1:
	clr Contador
	ldi lcd_col, 0
	rcall lcd_lin1_col

	ldi lcd_caracter, 'M'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'L'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'H'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter

	ldi lcd_number, 1
	rcall lcd_write_number
	ldi lcd_caracter, ':'
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	rcall lcd_write_caracter
	rcall Mostrador_Config
	rcall Config_Sistema_Calc
	sts Molho1, Contador ; Guarda valor tempo resfriamento
	clr Contador
	rcall Mostrador_Config
	ret

Config_Molho2:
	clr Contador
	ldi lcd_col, 0
	rcall lcd_lin1_col

	ldi lcd_caracter, 'M'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'L'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'H'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter

	ldi lcd_number, 2
	rcall lcd_write_number
	ldi lcd_caracter, ':'
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	rcall lcd_write_caracter
	rcall Mostrador_Config
	rcall Config_Sistema_Calc
	sts Molho2, Contador ; Guarda valor tempo resfriamento
	clr Contador
	rcall Mostrador_Config
	ret

Config_Centrifuga: ; configuracao da centrifuga
	clr Contador
	ldi lcd_col, 0
	rcall lcd_lin1_col

	ldi lcd_caracter, 'C'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'T'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'R'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'F'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'

	ldi lcd_caracter, ':'
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	rcall lcd_write_caracter
	ldi lcd_caracter, ' '
	rcall lcd_write_caracter
	rcall Mostrador_Config
	rcall Config_Sistema_Calc
	sts Centrifuga, Contador ; Guarda valor tempo resfriamento
	clr Contador
	rcall Mostrador_Config
	rcall lcd_clear
	ret

Config_Sistema_Calc: ; configura o sistema de calculo melhorado
	sbis pinc, BotaoMais
	rcall Somador_Config
	nop
	sbis pinc, BotaoMenos
	rcall Dim_Config
	nop
	sbic pinc, BotaoConfirm
	rjmp Config_Sistema_Calc
	rjmp Verificar_Config
continue:
	ldi delay_time, 1
	rcall delay_seconds
	ret

Verificar_Config:
	cpse Contador, r12
	rjmp continue
	rjmp Config_Sistema_Calc

Somador_Config:
	inc Contador
	ldi delay_time, 200
	rcall delay_miliseconds
	rcall Mostrador_Config
	ret

Arrumador:
	mov r16, Contador
	cp r16, r11
	brmi soma
	ret
soma:
	inc Contador
	ret

Dim_Config:
	dec Contador
	rcall Arrumador
	ldi delay_time, 200
	rcall delay_miliseconds
	rcall Mostrador_Config
	ret

Mostrador_Config:
	ldi lcd_col, 10
	rcall lcd_lin1_col
	mov lcd_number, Contador
	rcall lcd_write_number
	ret

Mensagem_Enchendo:
	rcall lcd_clear
	ldi lcd_col, 0
	rcall lcd_lin0_col
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'C'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'H'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'D'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ret

Mensagem_Esvaziando:
	rcall lcd_clear
	ldi lcd_col, 0
	rcall lcd_lin0_col
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'S'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'V'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'Z'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'D'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ret

Mensagem_Agitando:
	rcall lcd_clear
	ldi lcd_col, 0
	rcall lcd_lin0_col
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'G'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'T'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'D'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ret

Mensagem_Molho:
	rcall lcd_clear
	ldi lcd_col, 0
	rcall lcd_lin0_col
	ldi lcd_caracter, 'M'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'L'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'H'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
	ldi lcd_caracter, '.'
	rcall lcd_write_caracter
		
	ret

Mensagem_Centrifuga:
	rcall lcd_clear
	ldi lcd_col, 0
	rcall lcd_lin0_col
	ldi lcd_caracter, 'C'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'E'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'T'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'R'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'F'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'U'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'G'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'D'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ret

Final_Program:
	ldi lcd_col, 0
	rcall lcd_lin0_col
	ldi lcd_caracter, 'P'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'R'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'G'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'R'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'M'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	
	ldi lcd_col, 0
	rcall lcd_lin1_col
	ldi lcd_caracter, 'F'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'N'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'L'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'I'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'Z'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'A'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'D'
	rcall lcd_write_caracter
	ldi lcd_caracter, 'O'
	rcall lcd_write_caracter
	ret