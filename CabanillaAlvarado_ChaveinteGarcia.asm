    	#Jhon Steeven Cabanilla Alvarado
    	#Miguel Chaveinte García
    	#Grupo 301
.data 
	vector:		.space 	4000
	mensaje:	.asciiz "Introduzca las componentes del vector:\n"
	mensaje2:	.asciiz "Introduzca el valor que desee buscar:\n"
	mensaje3:	.asciiz "El valor se encuentra en (-1 si no esta en el vector): "
.text 
main:
	#Cargar los parametros
	la	$a2, vector
	li	$a1,0
	jal	item		# Llamamos a la funcion que nos guardara los items del vector
	#Imprimimos el mensaje del número que busca
	li	$v0, 4
	la	$a0, mensaje2
	syscall	
	#Leemos el entero
	li	$v0, 5
	syscall
	move 	$a0, $v0	#Guardamos en $a0 el valor buscado
	jal 	funcion		# Llamamos a la funcion que nos busca el indice
	#Imprimir k con su mensaje
	li	$v0, 4
	la	$a0, mensaje3
	syscall	
	li	$v0, 1
	move	$a0, $t2
	syscall 
	#Fin del programa
	li	$v0, 10
	syscall
item:
	#Función mediante la cual pedimos al vector los valores a introducir. Cuando 
	#introduce uno negativo vamos a la etiqueta fin que lo que nos hace es 
	#retornar a main ( fin tambien iguala $t2 =-1 pero eso es que hemos 
	#reutilizado esa etiqueta para funcion, y aqui no nos afecta esa asignación).
	#Parámetros: n(tamaño vector) y vector respectivamente en $a1 y $a2 para 
	#que en esta función se actualicen.
	
	#Imprimimos el mensaje para que nos den los items para el vector.
	la	$a0,mensaje
	li	$v0, 4
	syscall
	#Leer entero
	li 	$v0 , 5
	syscall	
	bltz	$v0,fin		#Si el numero introducido<0 va a fin.
	add	$t1,$t2,$a2	#Sino lo guarda.
	sw	$v0, 0($t1)
	addi	$a1, $a1, 1	#Indice para el numero de componentes(n) del vector.
	addi	$t2, $t2, 4	#Sumamos 4 para recorrer el vector.
	j	item
funcion:
	#Función iterativa mediante la cual recorremos un vector en busca de un valor 
	#cualquiera, devolviendo la posición en la que se encuentra o -1 si no está. 
	#Parámetros: x(número buscado),n(tamaño vector), vector respectivamente en $a0,$a1 y $a2.
	
	#Incializar variables
	li	$t0, 0		#principio
	move	$t1, $a1	#fin = n
	li	$t2, 0		#k
	li	$t3, 0		#k1
	j	do		# bucle do-while
do:	
	move	$t3, $t2	#k1=k
	add	$t4, $t0, $t1
	srl 	$t2, $t4, 1 	#En k tenemos la mitad del vector
	sll	$t6, $t2, 2	#Multiplicamos por 4 ya que se trata del índice de un vector guardandolo en $t6.
	add 	$t4, $a2, $t6	#En a2 tenemos cargado el vector
	lw 	$t5, 0($t4)	#Cargamos en $t5, vector[k]
	#IF v[k] != x
	bne	$t5, $a0, if
 	#Return k
	jr	$ra
if:
	#x > vector[k] 
	bge  	$a0, $t5, else	#Sino cumple condicion x > vector[k] a else.
	move 	$t1, $t2	#fin=k
	beq	$t2, $t3, fin	#k=k1 a fin.
	j 	do		#nueva iteracion.	
else:
	move	$t0, $t2	#principio=k
	beq	$t2, $t3, fin	#k=k1 a fin.
	addi	$t0,$t0,1	#principio=principio+1
	j	do	
fin:	
	li	$t2, -1		#k=-1 ya que no se ha encontrado x en el vector.
	jr	$ra
	





