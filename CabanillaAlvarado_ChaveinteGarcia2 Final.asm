    	#Jhon Steeven Cabanilla Alvarado
    	#Miguel Chaveinte García
    	#Grupo 301
    	
    	#Número total de instrucciones utilizando la versión iterativa: 442
    	#Número total de instrucciones utilizando la versión recursiva: 481
    	
    	#Por tanto, la versión iterativa respecto de la recursivaa es un 8.11% más rápdida
    	
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
	add	$v0,$zero,$zero
	jal 	funcion		# Llamamos a la funcion que nos busca el indice
	move	$v1,$v0		#Movemos a $v1, el índice que haya devuelto la función.
	#Imprimir k con su mensaje
	li	$v0, 4
	la	$a0, mensaje3
	syscall	
	li	$v0, 1
	move	$a0, $v1
	syscall 
	#Fin del programa
	li	$v0, 10
	syscall
item:
	#Función mediante la cual pedimos al vector los valores a introducir. Cuando 
	#introduce uno mayor que cero vamos a la etiqueta guardado que lo que nos hace es 
	#guardar los elementos, sino retorna. 
	#Parámetros: n(tamaño vector) y vector respectivamente en $a1 y $a2 para 
	#que en esta función se actualicen.
	
	#Imprimimos el mensaje para que nos den los items para el vector.
	la	$a0,mensaje
	li	$v0, 4
	syscall
	#Leer entero
	li 	$v0 , 5
	syscall	
	bgez 	$v0,guardado	#Si el numero introducido>0 va a guardado.	
	jr	$ra		#Sino retorna
guardado:	
	add	$t1,$t2,$a2	
	sw	$v0, 0($t1)	#Guardamos en vector
	addi	$a1, $a1, 1	#Indice para el numero de componentes(n) del vector.
	addi	$t2, $t2, 4	#Sumamos 4 para recorrer el vector.
	j	item		#Nueva iteracion
funcion:
	#Función mediante la hallamos el indice del número buscado recorriendo el vector 
	#en busqueda binaria recursiva.Devolverá la posición del indice en el que se 
	#encuentra dicho valor o -1 si este no ha sido encontrado.
	#Parámetros: x(número buscado),n(tamaño vector), vector respectivamente en $a0,$a1 y $a2.
	
	addi	$sp, $sp, -8	#reserva 2 lugares en la pila
	sw	$ra, 0($sp)	#guarda dirección de retorno
	sw	$a1,4($sp)	#guarda en pila n
	
	bne	$a1,$zero,encontrado	#n!=0: item encontrado
	li	$v0,-1		# i=-1
	j 	retornar
encontrado:
	srl 	$t1,$a1,1	#en $t1 tenemos la mitad del vector
	sll	$t2, $t1, 2	#Multiplicamos por 4 ya que se trata del índice de un vector guardandolo en $t6.
	add 	$t2, $a2, $t2	#En a2 tenemos cargado el vector
	lw 	$t3, 0($t2)	#Cargamos en $t5, vector[k]
	bne	$t3,$a0,nomitad	#Si V[n/2]!=item vamos a la etiqueta nomitad
	add	$v0,$t1,$zero	#retorna n/2
	j	retornar
nomitad:
	bge	$a0,$t3,else	#Si item>V[n/2],vamos a else.
	move	$a1,$t1		#n=n/2
	jal	funcion		#llamamos de nuevo a la funcion.
	bne	$v0,$zero,retornar	#Si $v0!=0, ultimo caso(i+n/2+1) y por lo tanto que retorne directamente(previa devolución de pila).
	add	$v0,$t1,$zero	#retorna i
	j	retornar	
else:
	addi	$t2,$t2,4	#V[n/2+1]
	move	$a2,$t2		#Para pasarlo de parametro de función.
	addi	$t1,$t1,1	#n/2+1
	sub	$a1,$a1,$t1	#n-n/2-1 y lo pasamos como parametro.
	jal	funcion		#llamamos de nuevo a la funcion.
	blt	$v0,$zero,retornar	#Si i<0,vamos a la etiqueta fin
	lw	$ra, 0($sp)	#recupera la direccion de retorno
	lw	$a1,4($sp)	#retorna el valor original de n
	addi	$sp, $sp, 8	#libera los 2 lugares de la pila
	srl 	$a1,$a1,1	#n/2
	addi	$a1,$a1,1	#n/2+1
	add	$v0,$v0,$a1	#i+n/2+1
	jr	$ra	
retornar:
	lw	$ra, 0($sp)	#recupera la direccion de retorno
	lw	$a1,4($sp)	#retorna el valor original de n
	addi	$sp, $sp, 8	#libera los 2 lugares de la pila
	jr	$ra