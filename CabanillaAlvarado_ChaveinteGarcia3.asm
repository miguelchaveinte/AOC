    	#Jhon Steeven Cabanilla Alvarado
    	#Miguel Chaveinte García
    	#Grupo 301
.data
	A:		.word 	0,1,2,3,4,5,6,7,8,9,1,10,11,12,0,13,14,4,0,0,0,0,8,0,0
	B:		.space	20
	mensaje:	.asciiz "Introduzca las componentes del vector (número negativo cuando quiera parar):\n"
	mensaje2:	.asciiz "El valor se encuentra en la fila(-1 si no esta en el vector): "
	mensaje3:	.asciiz "\nEl valor se encuentra en la columna(-1 si no esta en el vector): "
.text
	la	$a2, B
	li	$a1,0
	jal 	item
	la	$a0, A
	jal	buscafilas	#Llamamos a la función que nos encontrará el índice de las filas
	move 	$s0, $v0	#Trasladamos el return de la función a $s0
	jal	buscacolumnas	#Llamamos a la función que nos encontrará el índice de las columnas
	move	$s1,$v0		#Trasladamos el return de la función a $s1
	#Imprimimos el mensaje con sus indices
	li	$v0, 4
	la	$a0, mensaje2
	syscall	
	li	$v0, 1
	move	$a0, $s0
	syscall 
	li	$v0, 4
	la	$a0, mensaje3
	syscall	
	li	$v0, 1
	move	$a0, $s1
	syscall 
	li	$v0,10
	syscall

item:
	#Función mediante la cual pedimos al vector los valores a introducir. Cuando 
	#has introducido 5 valores esta retona.
	#Parámetros: n(tamaño vector) y vector B en $a2
	
	ble 	$a1,4,guardado	#Si n<=4 va a guardado.	
	jr	$ra		#Sino retorna
guardado:	
	#Imprimimos el mensaje para que nos den los items para el vector.
	la	$a0, mensaje
	li	$v0, 4
	syscall
	#Leer entero
	li 	$v0 , 5
	syscall	
	add	$t1,$t2,$a2	
	sw	$v0, 0($t1)	#Guardamos en vector
	addi	$a1, $a1, 1	#Indice para el numero de componentes(n) del vector.
	addi	$t2, $t2, 4	#Sumamos 4 para recorrer el vector.
	j	item		#Nueva iteracion
	
buscafilas:
	#Función mediante la cual obtenemos el índice de la fila en el que se encuentra el vector B.
	#Sino encuentra ninguna fila que coincida integramente con el vector retorna -1.
	#Parámetros: n(tamaño vector),vector B en $a2, matriz A en $a0.
	
	add 	$t0, $t0, $zero		#Indice para recorrer la matriz (i)
	add 	$t1, $zero, $zero	#Contador[j]
	ble 	$a1,$t0, retornar	#Si n < i va a retornar. Hemos recorrido toda la matriz sin exito.
	bgt	$a1, $t1, comprobar	#Si n>j(columna) va a comprobar que hace los calculos para A[i][j] y B[j]
newfila:
	addi	$t0, $t0, 1		#i++
	j	buscafilas
comprobar: 
	sll	$t9, $t1, 2 
	add	$t2, $a2, $t9
	lw	$t3, 0($t2)		#B[j]
	sll	$t4, $a1, 2		#4m
	mul	$t4, $t0, $t4		#4mi
	sll	$t5, $t1, 2		#4j
	add	$t6, $t4, $t5		#4mi + 4j
	add	$t7, $a0, $t6		
	lw	$t8, 0($t7)		#A[i][j]
	bne 	$t3, $t8, newfila	#Si A[i][j]!= B[j] va a newfila para comprobar la siguiente fila.
	addi 	$t1, $t1, 1		#j++
	bgt 	$a1, $t1, comprobar	#Si n>j comprobamos siguiente columna. Sino es que hemos recorrido una fila entera y coincide con B.
	move	$v0, $t0		#Retornamos el indice de la fila (i)
	li	$t0,0			#A cero ponemos los índices para poder utilizarlos en columna 
	li	$t1,0
	jr	$ra 			#Retornamos 
retornar:
	addi 	$v0, $zero, -1		#Devolvemos -1
	li	$t0,0
	jr	$ra

buscacolumnas:
	#Función mediante la cual obtenemos el índice de la columna en el que se encuentra el vector B.
	#Sino encuentra ninguna columna que coincida integramente con el vector retorna -1.
	#Parámetros: n(tamaño vector),vector B en $a2, matriz A en $a0.
	
	add 	$t0, $t0, $zero		#Indice para recorrer la matriz (j)
	add 	$t1, $zero, $zero	#Contador[i]
	ble 	$a1,$t0, retornar	# n < j va a retornar. Hemos recorrido toda la matriz sin exito.
	bgt	$a1, $t1, comprobarcol	#Si n>i(fila) va a comprobar que hace los calculos para A[i][j] y B[i]
newcolumna:
	addi	$t0, $t0, 1		#j++
	j	buscacolumnas

comprobarcol: 
	sll	$t9, $t1, 2 
	add	$t2, $a2, $t9
	lw	$t3, 0($t2)		#B[i]
	sll	$t4, $a1, 2		#4m
	mul	$t4, $t1, $t4		#4mi
	sll	$t5, $t0, 2		#4j
	add	$t6, $t4, $t5		#4mi + 4j
	add	$t7, $a0, $t6		
	lw	$t8, 0($t7)		#A[i][j]
	bne 	$t3, $t8, newcolumna	#Si A[i][j]!= B[i] va a newcolumna para comprobar la siguiente columna.
	addi 	$t1, $t1, 1		#i++
	bgt	$a1, $t1, comprobarcol	#Si n>i comprobamos siguiente fila. Sino es que hemos recorrido una columna entera y coincide con B.
	move	$v0, $t0		#Retornamos el indice de la fila (j)
	jr	$ra
	
	


