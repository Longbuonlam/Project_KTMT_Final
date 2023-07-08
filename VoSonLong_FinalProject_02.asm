.eqv SCREEN 	0x10010000	
.eqv RED 	0x00FF0000
.eqv BACKGROUND 	0x00000000
.eqv KEY_A 	0x00000061
.eqv KEY_S	0x00000073
.eqv KEY_D	0x00000064
.eqv KEY_W	0x00000077
.eqv KEY_ENTER	0x0000000a
.eqv DELTA_X	10
.eqv DELTA_Y	10
.eqv DELAY	150
.eqv KEY_CODE	0xFFFF0004
.eqv KEY_READY	0xFFFF0000

# Delay chuong trinh, Khoang thoi gian delay giua cac lan di chuyen cua hinh tron (ms)
.macro delay	
 	li $a0, DELAY
 	li $v0, 32 
 	syscall
.end_macro
	
.macro LessOrEqual(%r1, %r2, %branch)
	sle $v0, %r1, %r2	#so sanh r1 va r2, neu r1<=r2 thi v0=1, nguoc lai thi v0=0
 	bnez $v0, %branch 	#neu v0 khao 0 thi nhay den branch
.end_macro
	 
.macro 	DrawCirle_withColor(%color)
	li $s5, %color		#Dat mau den cho duong tron de xoa duong tron cu.
 	jal drawCircle		
.end_macro  

.kdata	
	CIRCLE_DATA: 	.space 512  
.text
 li $s0, 256	# Xo = 256		Toa do X cua tam duong tron
 li $s1, 256	# Yo = 256		Toa do Y cua tam duong tron
 li $s2, 24	# R = 24 		Ban kinh cua tam duong tron
 li $s3, 512	# SCREEN_WIDTH = 512	Do rong man hinh
 li $s4, 512	# SCREEN_HEIGHT = 512	Chieu cao man hinh
 li $s5, RED	#	Chon duong tron mau do
 li $s7, 0	#	dx = 0
 li $t8, 0	#	dy = 0  
 
 
 
 # Ham khoi dong duong tron
 # Tao mang du lieu luu toa do cac diem cua duong tron
 circleStore: 
	li $t0, 0		# i = 0
	la $t5, CIRCLE_DATA	# tro vao dia chi cua noi luu du lieu duong tron
 loop:	slt $v0, $t0, $s2	# for loop i -> R
	beqz $v0, end_circleStore
	mul $s6, $s2, $s2	# R^2
	mul $t3, $t0, $t0	# i^2
	sub $t3, $s6, $t3	# $t3 = R^2 - i^2   
	move $v0, $t3
	jal sqrt
				#
				#       / |
				#  R  /	  |  j
				#   /_____|
				# O    i
	sw $a0, 0($t5)		# Luu j = sqrt(R^2 - i^2) vao mang du lieu
	addi $t0, $t0, 1	# i++
	add $t5, $t5, 4		# Di den vi tri tiep theo luu du lieu cua CIRCLE_DATA
	j loop
	end_circleStore:
 
 # Ham nhap du lieu tu ban phim
 Loop:
 Keyboard:
 	lw $k1, KEY_READY 	# kiem tra da nhap ki tu nao chua
 	beqz $k1, Position	
 	lw $k0, KEY_CODE
 	beq $k0, KEY_A, case_a
 	beq $k0, KEY_S, case_s
 	beq $k0, KEY_D, case_d
 	beq $k0, KEY_W, case_w
 	beq $k0, KEY_ENTER, case_enter
 	j Position	
 	nop
 case_a:
 	jal moveLeft
 	j Position	
 case_s:
 	jal moveDown
 	j Position	
 case_d:
 	jal moveRight
 	j Position	
 case_w:
 	jal moveUp
 	j Position	
 case_enter: 
 	j endProgram
 	
 Position:		
 RightEdge:
 	add $v0, $s0, $s2	# Xo + R
 	add $v0, $v0,$s7	# If Xo + R + DELTA_X > SCREEN_WIDTH then moveLeft
 	LessOrEqual($v0, $s3, LeftEdge)	# else check left edge
 	jal moveLeft	
 	nop
 LeftEdge:
 	sub $v0, $s0, $s2	
 	add $v0, $v0, $s7	# If Xo - R + DELTA_X < 0 then moveRight
 	LessOrEqual($zero, $v0, TopEdge)	 # else check top edge	
 	jal moveRight	
 	nop
 TopEdge:
 	sub $v0, $s1, $s2	
 	add $v0, $v0, $t8	# If Yo - R + DELTA_Y < 0 then moveDown
 	LessOrEqual($zero, $v0, BottomEdge) # else check bottom edge
 	jal moveDown	
 	nop
 BottomEdge:
 	add $v0, $s1, $s2	
 	add $v0, $v0, $t8	# If Yo + R + DELTA_Y > SCREEN_HEIGHT then moveUp
 	LessOrEqual($v0, $s4, draw)	         # else all condition eligible, draw circle
 	jal moveUp				
 	nop
 	
# Ham ve duong tron
draw: 	
 	DrawCirle_withColor(BACKGROUND) # Ve duong tron trung mau nen
 	add $s0, $s0, $s7		# Cap nhat toa do moi cua duong tron
 	add $s1, $s1, $t8		
 
	DrawCirle_withColor(RED) 	# Ve duong tron moi
 	delay				# Dung chuong trinh 1 khoang thoi gian
 	j Loop
 	
endProgram:
	DrawCirle_withColor(BACKGROUND)
 	li $v0, 10
 	syscall


# Ham ve duong tron
# Su dung du lieu o mang CIRCLE_DATA tao boi circleStore	
 drawCircle:
	add $sp, $sp, -4
	sw $ra, 0($sp)
 	li $t0, 0		# khoi tao bien i = 0
 loop_drawCircle:
  	slt $v0, $t0, $s2   	# i -> R
 	beqz $v0,  end_drawCircle
	sll $t5, $t0, 2	
	lw $t3, CIRCLE_DATA($t5) # Load j to $t3	 
	
 	move $a0, $t0		# i = $a0
	move $a1, $t3		# j = $a1
	jal drawCirclePoint	# Draw (Xo + i, Yo + j), (Xo + j, Yo + i)
	sub $a1, $zero, $t3
	jal drawCirclePoint	# Draw (Xo + i, Yo - j), (Xo + j, Yo - i)
	sub $a0, $zero, $t0
	jal drawCirclePoint	# Draw (Xo - i, Yo - j), (Xo - j, Yo - i)
	add $a1, $zero, $t3
	jal drawCirclePoint	# Draw (Xo - i, Yo + j), (Xo - j, Yo + i)
	
	addi $t0, $t0, 1
	j loop_drawCircle
  end_drawCircle:
 	lw $ra, 0($sp)
 	add $sp, $sp, 0	
 	jr $ra
 

#	Ham ve diem tren duong tron
# 	Ve dong thoi 2 diem (X0 + i, Y0 +j ) va (Xo + j, Xo + i)
#	i = $a0, j = $a1
#	Xi =$t1, Yi = $t4

 drawCirclePoint:
 	
 	add $t1, $s0, $a0 	# Xi = X0 + i
	add $t4, $s1, $a1	# Yi = Y0 + j
	mul $t2, $t4, $s3	# Yi * SCREEN_WIDTH
	add $t1, $t1, $t2	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t1, $t1, 2		# Dia chi tuong doi cua diem anh
	sw $s5, SCREEN($t1)	# Ve anh
	add $t1, $s0, $a1 	# Xi = Xo + j
	add $t4, $s1, $a0	# Yi = Y0 + i
	mul $t2, $t4, $s3	# Yi * SCREEN_WIDTH
	add $t1, $t1, $t2	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t1, $t1, 2		# Dia chi tuong doi cua diem anh
	sw $s5, SCREEN($t1)	# Ve anh
	
	jr $ra
	

# Cac ham di chuyen

moveLeft:
	li $s7, -DELTA_X
 	li $t8, 0
	jr $ra 	
moveRight:
	li $s7, DELTA_X
 	li $t8, 0
	jr $ra 	
moveUp:
	li $s7, 0
 	li $t8, -DELTA_Y
	jr $ra 	
moveDown:
	li $s7, 0
 	li $t8, DELTA_Y
	jr $ra 
	

# Square Root
# de su dung floating point thi phai chuyen sang coprocessor	 				 				 				
# $v0 = S, $a0 = sqrt(S)

sqrt: 
	mtc1 $v0, $f0 # dua tu $v0 vao $f0
	cvt.s.w $f0, $f0 
	sqrt.s $f0, $f0
	cvt.w.s $f0, $f0 
	mfc1 $a0, $f0 # dua lai tu $f0 vao $a0
	jr $ra
