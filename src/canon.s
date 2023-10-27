.data
    .include "sprites/canon.data"
PI: .float 3.1415
ANGLE: .float 1.0472

.text
SETUP:
    # Tamanho da tela 320 x 240

    # li a0, 7
    # jal ra, FATORIAL

    # li a7, 1
    # ecall

    # li a7, 10
    # ecall



    la t0, ANGLE
    flw fa0, 0(t0)
    li a0, 7
    jal ra, COS

    li a7, 2
    ecall

    li a7, 10
    ecall

    


    # la a0, canon
    # li a1, 0
    # li a2, 208
    # li a3, 0
    # li a4, 0

    # jal ra, PRINT

LOOP: j LOOP

# =================== Função FATORIAL ===================

# a0 = numero

# t0 = numero a se multiplicar

# Retorna no a0

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

# t0 = index do loop
# ft0 = numero atual

# Retorna no fa0

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

# s0 = index do loop
# s1 = 1 se for pra adicionar 0 se for pra subtrair
# s2 = expoente / fatorial da serie de taylor
# s3 = precisao salva

# fs0 = resultado atual
# fs1 = angulo salvo

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

# s0 = index do loop
# s1 = 1 se for pra adicionar 0 se for pra subtrair
# s2 = expoente / fatorial da serie de taylor
# s3 = precisao salva

# fs0 = resultado atual
# fs1 = angulo salvo

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

# ===================== Função PRINT =====================

# Carrega um sprite na tela

# a0 = endereço imagem
# a1 = x
# a2 = y
# a3 = frame (0 ou 1)
# a4 = angulo (0 - 360)

# s0 = endereço do bitmap display
# s1 = endereço de imagem
# s2 = contador da linha
# s3 = contador da coluna
# s4 = largura
# s5 = altura
# s6 = angulo salvo

PRINT:
    addi sp, sp, -32
	sw ra, 28(sp)
	sw s6, 24(sp)
    sw s5, 20(sp)
	sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

    li s0, 0xFF0
    add s0, s0, a3
    slli s0, s0, 20

    add s0, s0, a1

    li s1, 320
    mul s1, s1, a2
    add s0, s0, s1

    addi s1, a0, 8

    mv s2, zero
    mv s3, zero

    lw s4, 0(a0)
    lw s5, 4(a0)

    mv s6, a4

PRINT_LINHA:
    lw t0, 0(s1)

    li t1, 199
    beq t0, s6, SKIP_PRINT

    sw t0, 0(s0)
SKIP_PRINT:

    addi s0, s0, 4
    addi s1, s1, 4

    addi s3, s3, 4
    blt s3, s4, PRINT_LINHA

NEXT_LINHA:
    addi s2, s2, 1
    mv s3, zero

    li t0, 320
    sub t0, t0, s4
    add s0, s0, t0

    blt s2, s5, PRINT_LINHA

PRINT_FIM:
	lw ra, 28(sp)
	lw s6, 24(sp)
    lw s5, 20(sp)
	lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
	lw s1, 4(sp)
	lw s0, 0(sp)

    addi sp, sp, 32

    jalr zero, ra, 0

# ========================================================