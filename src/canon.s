.data
PI: .float 3.1415
MIN_ANGLE: .float 0.1
MAX_ANGLE: .float 1.5
DEGREES_STEP: .float 0.1
START_DEGREE: .float 0.1

.text
SETUP:
    # fs0 = current angle
    # fs1 = min angle
    # fs2 = max angle
    # s0 = tamanho canhão
    # s1 = largura canhão

    la t0, START_DEGREE
    flw fs0, 0(t0)

    la t0, MIN_ANGLE
    flw fs1, 0(t0)

    la t0, MAX_ANGLE
    flw fs2, 0(t0)

    li s0, 15
    li s1, 60

    li a0, 1
    li a1, 220
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 255
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

GAME_LOOP:

KEYPOLL:
	li t0, 0xFF200000 # t0 = endereço de controle do teclado
	lw t1, 0(t0) # t1 = conteudo de t0
	andi t2, t1, 1 # Mascara o primeiro bit (verifica sem tem tecla)
	beqz t2, END_KEYPOLL # Se não tem tecla, então continua o jogo
	lw t1, 4(t0) # t1 = conteudo da tecla 
	
	li t0, 'w' # tecla de incrementar angulo
	beq t0, t1, SOBE_ANGULO
	
	li t0, 's' #tecla de decrementar angulo
	beq t0,t1, DESCE_ANGULO

    j REDRAW_CANON

SOBE_ANGULO:
    flt.s t0, fs2, fs0
    bne t0, zero, END_KEYPOLL

    # ========= Remover canhão =========

    li a0, 1
    li a1, 220
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 0
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    # ===================================

    la t0, DEGREES_STEP
    flw ft0, 0(t0)
    fadd.s fs0, fs0, ft0

    j REDRAW_CANON

DESCE_ANGULO:
    fle.s t0, fs0, fs1
    bne t0, zero, END_KEYPOLL

    # ========= Remover canhão =========

    li a0, 1
    li a1, 220
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 0
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    # ===================================

    la t0, DEGREES_STEP
    flw ft0, 0(t0)
    fsub.s fs0, fs0, ft0

REDRAW_CANON:
    # ========= Desenhar canhão =========

    li a0, 1
    li a1, 220
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 255
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    # ===================================

END_KEYPOLL:

    j GAME_LOOP

# =================== Função FATORIAL ===================

# a0 = numero

FATORIAL:
    beq a0, zero, FATORIAL_ZERO

    mv t0, a0
    li t1, 1

FATORIAL_LOOP:
    beq t0, t1, FATORIAL_END

    addi t0, t0, -1
    mul a0, a0, t0

    j FATORIAL_LOOP

FATORIAL_ZERO:
    li a0, 1

FATORIAL_END:
    jalr zero, ra, 0 # ret

# =======================================================

# ===================== Função POW =====================

# fa0 = base
# a0 = expoente

POW:
    li t0, 0

    li t1, 1
    fcvt.s.w ft0, t1

POW_LOOP:
    beq t0, a0, POW_END
    fmul.s ft0, ft0, fa0
    addi t0, t0, 1

    j POW_LOOP

POW_END:
    fmv.s fa0, ft0
    jalr zero, ra, 0 # ret

# ======================================================

# ===================== Função SIN =====================

# Calcula o seno de um angulo

# fa0 = angulo
# a0 = precisao (numeros da serie de taylor)

SIN:
    addi sp, sp, -36
	sw ra, 32(sp)
	sw a0, 28(sp)
	fsw fa0, 24(sp)
    sw s0, 20(sp)
	sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
	fsw fs0, 4(sp)
	fsw fs1, 0(sp)

    mv s0, zero
    li s1, 1
    li s2, 1
    mv s3, a0

    fcvt.s.w fs0, zero
    fmv.s fs1, fa0

SIN_LOOP:
    beq s0, s3, SIN_END

    fmv.s fa0, fs1
    mv a0, s2
    jal ra, POW

    mv a0, s2
    jal ra, FATORIAL

    fcvt.s.w ft0, a0
    fdiv.s ft0, fa0, ft0

    beq s1, zero, SUB_SIN_LOOP
    fadd.s fs0, fs0, ft0
    addi s1, s1, -1

    j AFTER_SIN_LOOP

SUB_SIN_LOOP:
    addi s1, s1, 1
    fsub.s fs0, fs0, ft0

AFTER_SIN_LOOP:
    addi s2, s2, 2
    addi s0, s0, 1

    j SIN_LOOP

SIN_END:
    fmv.s fa0, fs0
    
	lw ra, 32(sp)
    lw s0, 20(sp)
	lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
	flw fs0, 4(sp)
	flw fs1, 0(sp)

    addi sp, sp, 36

    jalr zero, ra, 0 # ret

# ======================================================

# ===================== Função COS =====================

# Calcula o cosseno de um angulo

# fa0 = angulo
# a0 = precisao (numeros da serie de taylor)

COS:
    addi sp, sp, -36
	sw ra, 32(sp)
	sw a0, 28(sp)
	fsw fa0, 24(sp)
    sw s0, 20(sp)
	sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
	fsw fs0, 4(sp)
	fsw fs1, 0(sp)

    mv s0, zero
    li s1, 1
    li s2, 0
    mv s3, a0

    fcvt.s.w fs0, zero
    fmv.s fs1, fa0

COS_LOOP:
    beq s0, s3, COS_END

    fmv.s fa0, fs1
    mv a0, s2
    jal ra, POW

    mv a0, s2
    jal ra, FATORIAL

    fcvt.s.w ft0, a0
    fdiv.s ft0, fa0, ft0

    beq s1, zero, SUB_COS_LOOP
    fadd.s fs0, fs0, ft0
    addi s1, s1, -1

    j AFTER_COS_LOOP

SUB_COS_LOOP:
    addi s1, s1, 1
    fsub.s fs0, fs0, ft0

AFTER_COS_LOOP:
    addi s2, s2, 2
    addi s0, s0, 1

    j COS_LOOP

COS_END:
    fmv.s fa0, fs0
    
	lw ra, 32(sp)
    lw s0, 20(sp)
	lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
	flw fs0, 4(sp)
	flw fs1, 0(sp)

    addi sp, sp, 36

    jalr zero, ra, 0 # ret

# ======================================================

# =================== Função PLACE_IN_BITMAP ===================

# a0 = endereço bitmap
# a1 = pos x
# a2 = pos y
# a3 = image pixel x
# a4 = image pixel y

PLACE_IN_BITMAP:
    add a0, a0, a1

    li t0, 320
    mul t0, a2, t0

    add a0, a0, t0

    add a0, a0, a3

    li t0, 320
    mul t0, a4, t0

    sub a0, a0, t0

    jalr zero, ra, 0 # ret

# =========================================================

# ================== Função CANHAO_LOOP ==================

# CANHAO_LOOP:
    

# ========================================================

# ================== Função DRAW_RECTANGLE ==================

# a0 = posx
# a1 = posy
# a2 = width
# a3 = height
# a4 = frame
# a4 = cor
# fa0 = angulo

# s0 = posx salva
# s1 = posy salva
# s2 = width salva
# s3 = height salva
# s4 = frame salvo
# s5 = cor

# fs0 = angulo salvo
# fs1 = x atual
# fs2 = y atual
# fs3 = x step = sin(ang)
# fs4 = y step = cos(ang)
# fs5 = x limite

DRAW_RECTANGLE:
    addi sp, sp, -52
	sw ra, 48(sp)
	fsw fs5, 44(sp)
	fsw fs4, 40(sp)
    fsw fs3, 36(sp)
    fsw fs2, 32(sp)
    fsw fs1, 28(sp)
    fsw fs0, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5

    # Salvar ângulo
    fmv.s fs0, fa0

    # X e Y atuais = zero
    fcvt.s.w fs1, zero
    fmv.s fs2, fs1

    # Calcular cosseno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, COS

    fmv.s fs4, fa0

    # Calcular seno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, SIN

    fmv.s fs3, fa0

    fcvt.s.w ft0, s2
    fmul.s fs5, fs3, ft0

DRAW_RECTANGLE_LOOP:
    fabs.s ft0, fs1
    fabs.s ft1, fs5
    flt.s t0, ft0, ft1
    beq t0, zero, DRAW_RECTANGLE_LOOP_END

    # Transformar posx e posy em inteiros
    fcvt.w.s t0, fs1
    add t0, t0, s0
    fcvt.w.s t1, fs2
    add t1, t1, s1

    mv a0, s3
    mv a1, s4
    mv a2, t0
    mv a3, t1
    mv a4, s5
    fmv.s fa0, fs0

    jal ra, DRAW_LINE

    fadd.s fs1, fs1, fs3
    fadd.s fs2, fs2, fs4

    j DRAW_RECTANGLE_LOOP

DRAW_RECTANGLE_LOOP_END:
	lw ra, 48(sp)
	flw fs5, 44(sp)
	flw fs4, 40(sp)
    flw fs3, 36(sp)
    flw fs2, 32(sp)
    flw fs1, 28(sp)
    flw fs0, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
	lw s1, 4(sp)
	lw s0, 0(sp)

    addi sp, sp, 52

    jalr zero, ra, 0 # ret

# ========================================================

# =================== Função DRAW_LINE ===================

# Desenha uma linha baseado no ângulo

# a0 = tamanho linha
# a1 = frame (0 ou 1)
# a2 = pos x
# a3 = pos y
# a4 = cor
# fa0 = ângulo (radiano)

# s0 = endereço do bitmap display
# s1 = contador do x
# s2 = posx guardada
# s3 = posy guardada
# s4 = tamanho da linha guardado
# s5 = cor
# fs0 = angulo guardado
# fs1 = altura
# fs2 = largura
# fs3 = tamanho step y (altura / largura)
# fs4 = contador do y

DRAW_LINE:
    addi sp, sp, -48
	sw ra, 44(sp)
	fsw fs4, 40(sp)
    fsw fs3, 36(sp)
    fsw fs2, 32(sp)
    fsw fs1, 28(sp)
    fsw fs0, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

    # Setup bitmap address based on frame
    li s0, 0xFF0
    add s0, s0, a1
    slli s0, s0, 20

    mv s1, zero
    mv s2, a2
    mv s3, a3
    mv s4, a0
    mv s5, a4

    # Salvar ângulo
    fmv.s fs0, fa0

    # Calcular seno
    li a0, 7
    # fmv.s fa0, fs0 # fa0 já é o ângulo
    jal ra, SIN

    fcvt.s.w ft0, s4 # tamanho linha
    fmul.s fs1, fa0, ft0 # sin(ang) * l = h

    # Calcular cosseno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, COS

    fcvt.s.w ft0, s4 # tamanho linha
    fmul.s fs2, fa0, ft0 # cos(ang) * l = w

    # Step do y = h / w
    fdiv.s fs3, fs1, fs2

    fcvt.s.w fs4, zero

DRAW_LINE_LOOP:
    # Se o x atual for maior ou igual a largura
    fcvt.w.s t0, fs2
    bge s1, t0, DRAW_LINE_LOOP_FIM

    # Escrever pixel branco nos x e y encontrados

    mv a0, s0 # endereço bitmap
    mv a1, s2
    mv a2, s3
    mv a3, s1

    fcvt.w.s t0, fs4 # y em int
    mv a4, t0

    jal ra, PLACE_IN_BITMAP

    # Repetir n vezes
    mv t1, zero

    fcvt.w.s t2, fs3 # Tamanho do step y
    addi t2, t2, 1
DRAW:
    beq t1, t2, DRAW_END
    sb s5, 0(a0)

    addi a0, a0, -320
    addi t1, t1, 1

    j DRAW
DRAW_END:
    addi s1, s1, 1
    fadd.s fs4, fs4, fs3

    j DRAW_LINE_LOOP

DRAW_LINE_LOOP_FIM:
	lw ra, 44(sp)
	flw fs4, 40(sp)
    flw fs3, 36(sp)
    flw fs2, 32(sp)
    flw fs1, 28(sp)
    flw fs0, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
	lw s1, 4(sp)
	lw s0, 0(sp)

    addi sp, sp, 48

    jalr zero, ra, 0

# ====================================================
