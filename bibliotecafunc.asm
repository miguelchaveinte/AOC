    	#Jhon Steeven Cabanilla Alvarado
    	#Miguel Chaveinte García
    	#Grupo 301

.data
cad_interna:  .asciiz "esto es una función de ejemplo que multiplica el argumento por 2\n"

.text 
#Función de ejemplo (eliminar para versión final)
funcExample:   
		move $t0, $a0
		la  $a0  cad_interna
  	        li   $v0 4  
	        syscall 
	        sll $v0, $t0, 1
	        jr $ra
	
#biblioteca de funciones del trabajo final	            
atoi:
	li	$t5,0
pre_sumaatoi:
	li	$v1,0
	li	$t3,0
	add	$t0,$a0,$zero		#Cargamos la dirección de A en $t0
bucle_atoi:
	lb	$t1,0($t0)		#A[0]
	beq	$t1,10,error		#Esta en blanco por lo que caracter invalid
	addi	$t4,$zero,1		# Marcamos en $t4 a 1 como flag de que es negativo
	addi	$t0,$t0,1		#i++
	beq	$t1,32,bucle_atoi
	beq	$t1,45,nonegativo		#A[0]!='-'  es no negativo
	addi	$t4,$zero,0
	beq	$t1,43,nonegativo
	addi	$t0,$t0,-1		#i++
	
espero_num:
	blt	$t1, 48, error		#Debe estar entre [0-9] los caracteres
	bgt	$t1, 57,error
nonegativo:
	lb	$t1,0($t0)		#A[i]
	blt	$t1, 48, error 		#AQUI SI QUE ERROR:Debe estar entre [0-9] los caracteres
	bgt	$t1, 57, error
	mul  	$t3,$t3,10		#Multiplicamos por 10 el resultado de esta interacción 
	mfhi	$t2			#Movemos a $t2 el apartado HI de la multiplicación  y para que haya sido correcta debe ser 0.
	bnez	$t2,error2
	mflo	$t2			#Movemos a $t2 el apartado LO de la multiplicación y para que haya sido correcta debe ser mayor que 0.
	bltz	$t2,error2
	move	$t3,$t2			#No hay error y por tanto la parte de LO pasa a $t3
	addi	$t1, $t1, -48		#Convertimos el caracter leido a int
	addu	$t3,$t1,$t3 		#Lo sumamos a lo que almacenabamos en $t3
	bgtu	$t3,0x7fffffff,error2	#Si es mayor que 2147483647 da error
	addi	$t0,$t0,1		#i++
	j	nonegativo		#nueva iteración


error:
	add	$t1,$zero,0
	lb	$t7,-1($t0)
	beq	$t7,48,sumar
	bnez	$t3,sumar
	add	$v1,$zero,2		#ponemos en $v1 el codigo de error 1
	move	$v0,$t3 		#movemos a $v0, la suma de los anteriores
	jr	$ra			#retorna
	
error2:
	beq	$t4,1,limite		#si es negativo tenemos que hacer otro analisis
	addi	$v1,$zero,1		#ponemos en $v1 el codigo de error 2
	addi	$v0,$zero,3		#movemos a $v0, la suma de los anteriores-> devolvemos cero???
	jr	$ra			#retorna
limite:
	add	$t4,$zero,$zero		#quitamos el flag
	bne	$t3,0x80000000,error2	#analizamos si es -2147483648. Sino es, se trata de un error de numero más grande. Sino se suma si es posible.

sumar:
	bgt	$t1, 48,error  	#Debe estar entre [0-9] los caracteres
	beq	$t4,1,negar		#es un negativo lo que vamos a sumar y queremos ver que no haya overflow en la suma.
	add	$t4,$zero,0x7fffffff	#cargamos 2147483647 para comparar
	subu	$t6,$t4,$t5		#restamos a el 2147483647, lo que tenemos en la suma. Es decir , obtenemos la diferencia que es lo máximo que podemos sumar
	bltz	$t5,continuar		#si $t5 es menor que 0, teniamos un negativo al que le sumamos un positivo por lo que todo bien.
	bgt	$t3,$t6,overflow		#si el numero que queremos sumar es mayor de lo máximo que podimos sumar(diferencia) por lo que nos daría un overflow en la suma total.
	add	$t5,$t5,$t3	
	move	$v0,$t5		#return suma total
	jr	$ra			#retornamos
negar:
	neg	$t3,$t3			#obtenemos el negativo 
	add	$t4,$zero,0x80000000	#comparamos con -2147483648
	subu	$t6,$t4,$t5
	bgtz	$t5,continuar		#si $t5 es mayor que 0, teniamos un positivoo al que le sumamos un negativo por lo que todo bien.
	bgt	$t6,$t3,overflow
	add	$t4,$zero,$zero	
	add	$t5,$t5,$t3
	move	$v0,$t5
	jr	$ra	

overflow:
	beqz	$t3,negar	#Tambien compruebe la parte del negativo
	addi	$v1,$zero,1	#Error 2 de numero grande
	addi	$v0,$zero,4	#retornamos el valor de la suma total -> retornar cero???
	jr	$ra
continuar:
	add	$t5,$t5,$t3
	move	$v0,$t5
	jr	$ra
	

###############################################################################################################################################
###############################################################################################################################################

itoa:
	#Función que guarda en una cadena B un int codificado en ascii,realizando los calculos para ello.
	#Parámetros de entrada: $a0:Vector B
	#		       $a1:Suma.Numero a convertir
	#Corrección respecto a la practica anterior:Modificación a guardar los carácteres a imprimir en una
	#cadena y no en un vector.
	move	$t0,$a1		#Direccion del vector	
	bgez   	$a0, loop	#Si suma>=0,no es negativo por tanto al bucle de dividir
	li	$t1, '-'		#Es negativo y guardamos el "-" en la B[0]
	sb	$t1, 0($t0)	
	addi	$t0, $t0, 1	#Contador i  
	addi	$a1,$a1,1	#Contador inicio
	beq	$a0,0x80000000,extremo	#Si el numero es -2147483648 hay que hacerle un tratamiento especial para imprimirlo ya que no podemos tener su opuesto en memoria.
	neg	$a0,$a0		#Al ser negativo, ponemos en $a1 su opuesto para hacer las divisiones con el positivo.
loop:	
	div	$t1, $a0, 10	#$t1=suma/10
	mflo	$a0		#$a1= cociente
	mfhi	$t2		#t2 resto	
	addi	$t2, $t2, 48	#Pasar el valor a Ascii
	sb	$t2, 0($t0)	#Guardamos en cadena
	addi	$t0, $t0, 1	#i++
	sb	$zero,0($t0)	
	beq	$a0, $zero, giracadena	#En el momento que el cociente sea 0 dejamos de dividir	
	j 	loop	
giracadena:
	bge	$a1, $t0, devolver	#S el contador inicio>=fin,retorna
	addi	$t3, $t0, -1	#El final es el caracter anterior al nulo
	lb	$t4,0($t3)	#en $t4=B[fin-1]
	move	$t2,$a1
	lb	$t1, 0($t2)	#Obtener el primer caracter(y que no es -,si fuera negativo) que irá al final
	sb	$t1, 0($t3)	#B[fin-1]=B[inicio]
	sb	$t4, 0($t2)	#B[inicio]=B[fin-1]
	addi	$a1,$a1,1	#inicio++
	addi	$t0, $t0, -1	#fin--
	j	giracadena
extremo:
	addiu	$a0,$a0,-1	#restamos 1 a -2147483648 sin overflow lo que nos dará el 2147483647
	div	$t1, $a0, 10	#$t1=suma/10
	mflo	$a0		#$a1= cociente
	add	$t2,$zero,56	#guardo el numero 8 en vez del 7 
	sb	$t2, 0($t0)	#Guardamos en cadena
	addi	$t0, $t0, 1	#i++
	sb	$zero,0($t0)
	j	loop	
devolver:
	jr	$ra	

###############################################################################################################################################
###############################################################################################################################################
	
strcmp:	
	addi 	$sp, $sp, -12 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp) 
	move	$s0,$a0
	move	$s1,$a1
	li	$a2,2147483647
	jal	strncmp
	move	$a0,$s0
	move	$a1,$s1
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	addi 	$sp, $sp, 12
	jr	$ra 

###############################################################################################################################################
###############################################################################################################################################

strncmp:
	li	$v0,0
	li	$v1,0
	li	$t2,0
	bgez	$a2,bucle_strncmp
	beqz	$a2,devolver_strncmp
	li	$v1,1
	jr	$ra
bucle_strncmp:
	
	bge	$t2,$a2,devolver_strncmp	#si contador>=nºde caracteres a comprobar
	add	$t0,$a0,$t2
	add	$t1,$a1,$t2
	lb	$t3,0($t0)
	lb	$t4,0($t1)
	add	$t5,$t3,$t4
	beqz	$t5,devolver_strncmp
	addi	$t0,$t0,1
	addi	$t2,$t2,1
	beq	$t3,$t4,bucle_strncmp
	blt	$t3,$t4,menor_acero
	li	$v0,1
	jr	$ra
menor_acero:
	li	$v0,-1
	jr	$ra	
devolver_strncmp:
	li	$v0,0
	jr	$ra
	
###############################################################################################################################################
###############################################################################################################################################
	   
strSearch:
	li	$v0,0
	li	$t3,0
	li	$t0,0
	add	$t0,$a0,$t0
nueva_busqueda:
	li	$t1,0
	add	$t1,$a1,$t1
bucle_strSearch:
	sub	$t5,$t1,$a1
	lb	$t2,0($t1)
	beq	$t2,0,retornar_strSearch
	lb	$t4,0($t0)
	beq	$t4,0,retornar_strSearch
	addi	$t0,$t0,1
	bne	$t2,$t4,nueva_busqueda
	addi	$t1,$t1,1
	j	bucle_strSearch
retornar_strSearch:
	beq	$t1,$a1,no_encontradostr
	bne	$t2,0,no_encontradostr
	sub	$t3,$t0,$a0
	sub	$t5,$t3,$t5
	move	$v0,$t5
	jr	$ra
	
no_encontradostr:
	li	$v0,-1
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################

containsChar:
	add	$t1,$a0,$zero
	bne	$a1,0,continuar_contains
	add	$v0,$zero,$zero
	jr	$ra
continuar_contains:
	lb	$t2,0($t1)
	beq	$t2,0,no_contenido
	add	$t1,$t1,1
	bne	$t2,$a1,continuar_contains
	add	$v0,$zero,$zero
	jr	$ra
no_contenido:
	addi	$v0,$zero,1
	jr	$ra
	
###############################################################################################################################################
###############################################################################################################################################

containsAnyChar:
	add	$t0, $a0, $zero
	add	$t2, $a1, $zero
	move	$t4, $t0
seguir_any:
	lb	$t3, 0($t2)		#Primer caracter del string_abuscar
	beq	$t3, 0, fin_2any		#El bucle acabara cuando lleguemos el carcter nulo de la cadena a buscar
	
forany:	
	lb	$t1, 0($t0)		#Primer caracter del string_busqueda
	beq	$t1, 0, ajusteany		#Si llegamos al fin de cadena y no hemos encontrado el caracter, este no esta 

	beq	$t1, $t3, fin_1any
	addi	$t0, $t0, 1		
	j	forany
	
ajusteany:	#Pasar al siguiente caracter del string_abuscar
	addi	$t2, $t2, 1
	move 	$t0, $t4		#Inicializamos de nuevo el registro para comenzar desde el primer caracter de string_busqueda
	j	seguir_any
fin_1any:
	#Se cumple la condicion
	add	$v0,$zero,0
	jr	$ra
fin_2any: 
	#No se cumple la condicion
	add	$v0,$zero, 1
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################

containsSomeChars:
	li	$t0,0
	li	$t5,0
	li	$v0,0
	li	$v1,0
hacer_some:
	blt	$a2,1,error_some
	add	$t1,$a1,$t0
	addi 	$sp, $sp, -20 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp)
	sw	$s2,12($sp) 
	sw	$s3,16($sp)
	move	$s0,$a0
	move	$s1,$a1
	move	$s2,$a2
	move	$s3,$t0
	lb	$a1,0($t1)
	beq	$a1,0,analizar_longitud
	jal	containsChar
	move	$a0,$s0
	move	$a1,$s1
	move	$a2,$s2
	move	$t0,$s3
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	lw	$s2,12($sp) 
	lw	$s3,16($sp) 
	addi 	$sp, $sp, 20
	beqz	$v0,sumar_some
	addi	$t0,$t0,1
	j	hacer_some	
sumar_some:
	addi	$t5,$t5,1
	addi	$t0,$t0,1
	j	hacer_some
analizar_longitud:
	bgt	$a2,$t0,error_some
	bge	$t5,$a2,cumplido
	addi	$v0,$zero,1
	jr	$ra
cumplido:
	li	$v0,0
	jr	$ra
	 
error_some:
	li	$v1,1
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################
	
containsAllChars:
	li	$v0,0
	li	$t0,0
	lb	$t1,0($a0)
	beqz	$t1,todobien_all
hacer_all:
	add	$t1,$a1,$t0
	addi 	$sp, $sp, -16 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp) 
	sw 	$s2, 12($sp) 
	move	$s0,$a0
	move	$s1,$a1
	move	$s2,$t0
	lb	$a1,0($t1)
	beqz	$a1,todobien_all
	jal	containsChar
	move	$a0,$s0
	move	$a1,$s1
	move	$t0,$s2
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	lw 	$s2, 12($sp) 
	addi 	$sp, $sp, 16
	addi	$t0,$t0,1
	beqz	$v0,hacer_all
	li	$v0,1
	jr	$ra
todobien_all:
	li	$v0,0
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################
	
containsOnlyChars:
	li	$v0,0
	li	$t0,0
hacer_only:
	add	$t1,$a0,$t0
	addi 	$sp, $sp, -16 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp) 
	sw 	$s2, 12($sp) 
	move	$s0,$a0
	move	$s1,$a1
	move	$s2,$t0
	move	$a0,$a1
	lb	$a1,0($t1)
	beqz	$a1,todobien_only
	jal	containsChar
	move	$a0,$s0
	move	$a1,$s1
	move	$t0,$s2
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	lw 	$s2, 12($sp)
	addi 	$sp, $sp, 16
	addi	$t0,$t0,1
	beqz	$v0,hacer_only	
	li	$v0,1
	jr	$ra
todobien_only:
	li	$v0,0
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################
			
countTokens:
	li	$v0,0
	li	$t7,0
	li	$t2,0
	add	$t0,$a0,$zero
while_tokens:
	lb	$t1, 0($t0)			#Primer caracter del string_abuscar
	beq	$t1, 0, fin_token		#El bucle acabara cuando lleguemos el carcter nulo de la cadena a buscar
	
	bne	$t1, $a1, token
	
	addi	$t0, $t0, 1			#Pasamos el siguiente caracter del String
	sub 	$t7, $t7, $t7	
	j	while_tokens
	
token:
	beq	$t7, 0, cont_token 	
	addi	$t0, $t0, 1	
	j	while_tokens
	
cont_token:
	addi	$t2, $t2, 1			#CONTADOR TOKENS	
	addi	$t0, $t0, 1	
	addi	$t7, $t7, 1
	j	while_tokens
	
fin_token:	
	move	$v0, $t2
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################

getToken:
	li	$v0,0
	li	$v1,0
	li	$t2,0		#token+1
	li	$t3,0		#contador apariciones
	li	$t6,0		#memoria iniico
	bltz 	$a2, error_token1
	
	addi 	$sp, $sp, -12 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp) 
	move	$s0,$a0
	move	$s1,$a1
	jal	countTokens
	move	$a0,$s0
	move	$a1,$s1
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	addi 	$sp, $sp, 12 # reserva un lugar en la pil
	
	bge	$a2,$v0,error_token1
	
	add	$t0,$a0,$zero
	add	$t7,$a3,$zero
	add	$t6,$t0,$zero
	beq	$v0,1,save_cadena
	lb	$t1,0($t0)
	beq	$t1,$a1,while_get
	subi	$a2,$a2,1
	bltz	$a2,save_cadena

while_get:
	lb	$t1,0($t0)
	beq	$t1,$a1,suma_get
	addi	$t0,$t0,1
	j	while_get	
	
suma_get:
	addi	$t0,$t0,1
	lb	$t1,0($t0)
	beq	$t1,$a1,suma_get
	addi	$t6,$t0,0
	beq	$t3,$a2,save_cadena
	addi	$t3,$t3,1
	j	while_get
	
	
guardar_ini:
	addi	$t6,$t0,1
save_cadena:
	lb	$t1,0($t6)
	beq	$t1,0,fin_get
	addi	$t6,$t6,1
	sb	$t1,0($t7)
	lb	$t1,0($t6)
	beq	$t1,0,fin_get
	beq	$t1,$a1,fin_get
	addi	$t7,$t7,1
	j	save_cadena
fin_get:
	addi	$t1,$zero,0
	addi	$t7,$t7,1
	sb	$t1,0($t7)
	move	$v0,$a3
	jr	$ra
error_token1:
	li	$v1,1
	jr	$ra

###############################################################################################################################################
###############################################################################################################################################
	
splitAtToken:
	li	$v0,0
	li	$v1,0
	li	$t2,0		#token+1
	li	$t3,0		#contador apariciones
	li	$t6,0		#memoria iniico
	bltz 	$a2, error_token1split
	
	addi 	$sp, $sp, -12 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp) 
	move	$s0,$a0
	move	$s1,$a1
	jal	countTokens
	move	$a0,$s0
	move	$a1,$s1
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	addi 	$sp, $sp, 12 # reserva un lugar en la pil
	
	bge	$a2,$v0,error_token1split
	
	add	$t0,$a0,$zero
	add	$t7,$a3,$zero
	add	$t6,$t0,$zero
	beq	$v0,1,save_cadenasplit
	lb	$t1,0($t0)
	beq	$t1,$a1,while_split
	subi	$a2,$a2,1
	bltz	$a2,save_cadenasplit

while_split:
	lb	$t1,0($t0)
	beq	$t1,$a1,suma_split
	addi	$t0,$t0,1
	j	while_split	
	
suma_split:
	addi	$t0,$t0,1
	lb	$t1,0($t0)
	beq	$t1,$a1,suma_split
	addi	$t6,$t0,0
	beq	$t3,$a2,save_cadenasplit
	addi	$t3,$t3,1
	j	while_split
	
save_cadenasplit:
	move	$v0,$t6
	lb	$t1,1($t6)
	jr	$ra
error_token1split:
	li	$v1,1
	jr	$ra
	

###############################################################################################################################################
###############################################################################################################################################
	
sumaNumTokens:
li	$v0,0
	li	$v1,0
	li	$t5,0
	beq	$a2, 0, error_sumToken1
	beq	$a2, 45, error_sumToken1
	beq	$a2, 43, error_sumToken1
	blt  	$a2, 48, bucle_sumToken
	bgt   	$a2, 57, bucle_sumToken
	li	$v1,1
	jr	$ra

bucle_sumToken:

 	addi 	$sp, $sp, -16 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp)
	sw	$s2,12($sp) 
	move	$s0,$a0
	move	$s1,$a1
	move	$s2,$a2
	move	$a1,$a2
	jal	countTokens
	move	$a0,$s0
	move	$a1,$s1
	move	$a2,$s2
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	lw	$s2,12($sp)
	addi 	$sp, $sp, 16 # reserva un lugar en la pil
	
	addi	$a3,$v0,-1	#numero de tokens
bucle_sumGet:	
	addi 	$sp, $sp, -20 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp)
	sw	$s2,12($sp) 
	sw	$s3,16($sp)
	move	$s0,$a0
	move	$s1,$a1
	move	$s2,$a2
	move	$s3,$a3
	move	$t8,$a2
	move	$a2,$a3
	move	$a3,$a1
	move	$a1,$t8
	jal	getToken
	move	$a0,$a3
	jal	pre_sumaatoi
	move	$a0,$s0
	move	$a1,$s1
	move	$a2,$s2
	move	$a3,$s3
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addi 	$sp, $sp, 20 # reserva un lugar en la pi
	beq	$v1,2,error_sumToken2
	beq	$v1,1,error_sumToken3
	addi	$a3,$a3,-1	
	add	$t2,$a1,$zero
limpiarcadena:
	sb	$zero,0($t2)
	addi	$t2,$t2,1
	lb	$t3,0($t2)
	bnez	$t3,limpiarcadena
	bltz	$a3,bucle_itoasum
	j	bucle_sumGet
 	
error_sumToken1:
	li	$v1,1
	jr	$ra
error_sumToken2:
	li	$v1,2
	jr	$ra
error_sumToken3:
	move	$v1,$v0
	jr	$ra
bucle_itoasum:
	move	$t0,$v0
	addi 	$sp, $sp, -16 # reserva un lugar en la pila
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)  
	sw 	$s1, 8($sp)
	sw	$s2,12($sp) 
	move	$s0,$a0
	move	$s1,$a1
	move	$s2,$a2
	move	$a0,$v0
	jal	itoa
	move	$a0,$s0
	move	$a1,$s1
	move	$a2,$s2
	move	$a3,$s3
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)  
	lw 	$s1, 8($sp)
	lw	$s2,12($sp)
	addi 	$sp, $sp, 16 # reserva un lugar en la pi
	jr	$ra		
			
