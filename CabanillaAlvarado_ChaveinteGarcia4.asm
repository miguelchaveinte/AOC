	#Jhon Steeven Cabanilla Alvarado
    	#Miguel Chaveinte Garcia
    	#Grupo 301
.data
	mensaje:	.asciiz "Inserte un número cualquiera: "
	A:		.word 4000
.text
	#Imprimimos el mensaje
	li	$v0, 4
	la	$a0, mensaje		#poner como parametro*******
	syscall	
	#Leemos el entero
	li	$v0, 5
	syscall
	move 	$a1, $v0
	
	la	$a0, A
	 
	jal	funcion
	
	li	$v0, 10
	syscall
	 
funcion: 
	#añadir cola!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	move	$t0,$a0		#Direccion del vector	
	bgez   	$a1, loop
	li	$t1, '-'
	sw	$t1, 0($t0)	#Guardamos en vector
	addi	$t0, $t0, 4	#Sumamos 
	addi	$a0,$a0,4
	neg	$a1,$a1	
loop:	
	div	$t1, $a1, 10
	mflo	$a1		#$a1= cociente
	mfhi	$t2		#t2 resto	
	addi	$t2, $t2, 48	#Pasar el valor a Ascii
	sw	$t2, 0($t0)	#Guardamos en vector
	addi	$t0, $t0, 4	#Sumamos 
	sw	$zero,0($t0)	
	beq	$a1, $zero, giracadena	#En el momento que el cociente sea 0 dejamos de dividir	
	j 	loop

#Función auxiliar para dar la vuelta a la cadena
	
giracadena:
	bge	$a0, $t0, retorno
	addi	$t3, $t0, -4	#El final es el caracter anterior al nulo
	lw	$t4,0($t3)
	move	$t2,$a0
	lw	$t1, 0($t2)	#Obtener el primer caracter que irá al final
	sw	$t1, 0($t3)
	sw	$t4, 0($t2)	
	addi	$a0,$a0,4
	addi	$t0, $t0, -4
	j	giracadena

retorno:
	jr	$ra