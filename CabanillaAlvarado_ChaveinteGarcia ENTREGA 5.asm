    	#Jhon Steeven Cabanilla Alvarado
    	#Miguel Chaveinte García
    	#Grupo 301
.data
	mensaje:	.asciiz "Inserte un numero cualquiera: "
	errorcarac:"El numero introducido contiene caracteres no validos o la cadena introducida es vacia\n"
	errorgrande:"El numero es mayor que 2*31(demasiado grande)\n"
	errorover:"Se ha producido un overflow en la suma total > 2*31 con el último número introducido\n"
	final:"La suma de los numeros anteriores es: "
	A:	.asciiz ""
	B:	.asciiz ""
.text
bucle:
	#Imprimimos mensaje de peticion de cadena
	li	$v0, 4
	la	$a0, mensaje	
	syscall	
	#Leemos cadena de caracteres
	li	$v0, 8
	la	$a0, A
	li	$a1, 100		#Longitud máxima de la cadena leida
	syscall
	add	$v0,$zero,$zero	#Ponemos a 0 $v0 para elimirar cualquier valor extraño
	jal 	atoi		#Llamamos a la funcion que checkea el numero y si es correcto lo suma.
	move	$s0,$v0		#El resultado del total de la suma lo almacenamos en $s0 
	bne	$v1,$zero,mensajeerror	#Si $v1 != 0 es que se produjo un error
	add	$t3,$zero,$zero	#borramos el valor de la variable $t3 que es el valor introducido anteriormente
	j	bucle		#nueva iteración
	#Fin del programa
	li	$v0, 10
	syscall
mensajeerror:
	beq	$v1,1,carac	#Si es el error 1(carácteres invalidos) va a carac
	li	$v0, 4		#Imprimimos mensaje de nº grandes
	la	$a0, errorgrande	
	syscall	
	la	$a0,B		#Cargamos en $a0 la cadena B
	move	$a1,$s0		#Movemos el resultado a $a1 para pasarlo a la función
	jal	imprimir
	li	$v0, 4		#Imprimimos la cadena de la suma
	la	$a0, final	
	syscall	
	li	$v0, 4		#Imprimimos el string del numero suma
	la	$a0, B	
	syscall	
	#Fin del programa
	li	$v0, 10
	syscall
carac:
	li	$v0, 4		#Imprimimos error de caracteres
	la	$a0, errorcarac	
	syscall	
	la	$a0,B		#Cargamos en $a0, el vector 
	move	$a1,$s0		#Movemos el resultado a $a1 para pasarlo a la función
	jal	imprimir
	li	$v0, 4		#Imprimimos la cadena de la suma
	la	$a0, final	
	syscall	
	li	$v0, 4		#Imprimimos el string del numero suma
	la	$a0, B	
	syscall	
	#Fin del programa
	li	$v0, 10
	syscall
imprimir: 
	#Función que guarda en una cadena B un int codificado en ascii,realizando los calculos para ello.
	#Parámetros de entrada: $a0:Vector B
	#		       $a1:Suma.Numero a convertir
	#Corrección respecto a la practica anterior:Modificación a guardar los carácteres a imprimir en una
	#cadena y no en un vector.
	addi	$sp, $sp, -12	#reserva 3 lugares en la pila
	sw	$ra, 0($sp)	#guarda dirección de retorno
	sw	$a0,4($sp)	#guarda en pila $a0=B
	sw	$a1,8($sp)	#guarda en pila $a1=suma
	move	$t0,$a0		#Direccion del vector	
	bgez   	$a1, loop	#Si suma>=0,no es negativo por tanto al bucle de dividir
	li	$t1, '-'		#Es negativo y guardamos el "-" en la B[0]
	sb	$t1, 0($t0)	
	addi	$t0, $t0, 1	#Contador i  
	addi	$a0,$a0,1	#Contador inicio
	beq	$a1,0x80000000,extremo	#Si el numero es -2147483648 hay que hacerle un tratamiento especial para imprimirlo ya que no podemos tener su opuesto en memoria.
	neg	$a1,$a1		#Al ser negativo, ponemos en $a1 su opuesto para hacer las divisiones con el positivo.
loop:	
	div	$t1, $a1, 10	#$t1=suma/10
	mflo	$a1		#$a1= cociente
	mfhi	$t2		#t2 resto	
	addi	$t2, $t2, 48	#Pasar el valor a Ascii
	sb	$t2, 0($t0)	#Guardamos en cadena
	addi	$t0, $t0, 1	#i++
	sb	$zero,0($t0)	
	beq	$a1, $zero, giracadena	#En el momento que el cociente sea 0 dejamos de dividir	
	j 	loop	
giracadena:
	bge	$a0, $t0, devolver	#S el contador inicio>=fin,retorna
	addi	$t3, $t0, -1	#El final es el caracter anterior al nulo
	lb	$t4,0($t3)	#en $t4=B[fin-1]
	move	$t2,$a0
	lb	$t1, 0($t2)	#Obtener el primer caracter(y que no es -,si fuera negativo) que irá al final
	sb	$t1, 0($t3)	#B[fin-1]=B[inicio]
	sb	$t4, 0($t2)	#B[inicio]=B[fin-1]
	addi	$a0,$a0,1	#inicio++
	addi	$t0, $t0, -1	#fin--
	j	giracadena
extremo:
	addiu	$a1,$a1,-1	#restamos 1 a -2147483648 sin overflow lo que nos dará el 2147483647
	div	$t1, $a1, 10	#$t1=suma/10
	mflo	$a1		#$a1= cociente
	add	$t2,$zero,56	#guardo el numero 8 en vez del 7 
	sb	$t2, 0($t0)	#Guardamos en cadena
	addi	$t0, $t0, 1	#i++
	sb	$zero,0($t0)
	j	loop	
	
devolver:
	lw	$ra, 0($sp)	#recupera la direccion de retorno
	lw	$a0,4($sp)	#retorna la direccion de B
	lw	$a1,8($sp)	#retorna el valor de la diferencia
	addi	$sp, $sp, 12	#libera los 3 lugares de la pila
	jr	$ra

atoi:
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