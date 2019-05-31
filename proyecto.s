@ -----------------------------------
@ Universidad del Valle de Guatemala
@ Organizacion de Computadoras y Assembler
@ Luis Alejandro Urbina-18473
@ Gerardo Mendez-18239
@ Stepper controller program made as the
@ final project of the course
@ ----------------------------------
@ Build:
@ gcc -c phys_to_virt.c
@ as -o gpio0_2.o gpio0_2.s -g
@ as -o proyecto.o proyecto.s -g
@ gcc -o anyName proyecto.o gpio0_2.o phys_to_virt.o
@ sudo ./nameYouChoseOnFirstStep 
@ -----------------------------------

.text
.align 2
.global main


main:
    /* utilizando la biblioteca GPIO (gpio0_2.s) */
	bl GetGpioAddress /*Se llama solo una vez*/

    /* DECLARACION DE PUERTOS GPIO COMO PUERTOS DE SALIDA */
    @GPIO para escritura (salida) puerto 14
	mov r0,#14
	mov r1,#1
	bl SetGpioFunction

    @GPIO para escritura (salida) puerto 15
	mov r0,#15
	mov r1,#1
	bl SetGpioFunction

    @GPIO para escritura (salida) puerto 23
	mov r0,#23
	mov r1,#1
	bl SetGpioFunction

    @GPIO para escritura (salida) puerto 24
	mov r0,#24
	mov r1,#1
	bl SetGpioFunction

    /* DECLARACION DE PUERTOS GPIO COMO PUERTOS DE ENTRADA */

    @GPIO para lectura (entrada) puerto 17
	mov r0,#17
	mov r1,#0
	bl SetGpioFunction

    @GPIO para lectura (entrada) puerto 22
	mov r0,#22
	mov r1,#0
	bl SetGpioFunction

    @GPIO para lectura (entrada) puerto 27
	mov r0,#27
	mov r1,#0
	bl SetGpioFunction

	@GPIO para lectura (entrada) puerto 25
	mov r0,#25
	mov r1,#0
	bl SetGpioFunction

	mov r0, #0
	mov r1, #0

	b dataInput

dataInput: /* Solicita que ingrese una de las opciones del menu principal */
    ldr r0, =menu_txt
	bl puts

	ldr r0,=formatoIngreso /*Mostrar menu*/
    ldr r1,=opcion
    bl scanf

    ldr r1,=opcion /* carga la opcion seleccionada*/
    ldr r1,[r1]
    
	cmp r1,#1 /* Compara si lo ingresado es 1 */

    bne teclado /* Si selecciona 2, se va a teclado */
	beq botones /* Si selecciona 1, se va a botones */
	/*mov pc, lr*/

botones: /* Etiqueta que da inicio a la rutina de ingreso de datos por botones */
	ldr r0,=menu_opciones_botones /* Muestra el menú de ingreso mediante botones */
    bl puts
	
    solicitud:
        mov r0,#17 /* Verificar estado de GPIO 17 */
        mov r1,#1
        bl GetGpio

        cmp r0,#1
        beq aumentar /* aumenta la velocidad del stepper */

        mov r0,#22 /* Verificar estado de GPIO 22 */
        mov r1,#1
        bl GetGpio

        cmp r0,#1
        beq disminuir /* disminuye la velocidad del stepper */

        mov r0,#27 /* Verificar estado de GPIO 27 */
        mov r1,#1
        bl GetGpio

        cmp r0,#1
        beq invertir /* invierte la direccion del stepper */

		mov r0,#25 /* Verificar estado de GPIO 25 */
        mov r1,#1
        bl GetGpio

        cmp r0,#1
        beq dataInput /* Regresa al menu principal  */

        b solicitud /* El ciclo se repite hasta que aglgun boton se presione */
    
    aumentar:
		/* Resta a delayHex deltaDelay para disminuir el tiempo de espera para wait */
        ldr r1,=delayHex
        ldr r1,[r1]

        ldr r0,=deltaDelay
        ldr r0,[r0]

        sub r1,r1,r0

        ldr r5,=delayHex @Aqui es donde se pasa lo de r5 y r10 
        str r1,[r5]

		/* Mover a r10 un contador para que dé la vuelta completa */
		mov r10, #500
		/* Cargar en r5 el delayHex para extablecer la velocidad */
		ldr r5, =delayHex
		ldr r5, [r5]

        bl clockWise

        b solicitud

    disminuir:
		/* Suma a delayHex deltaDelay para aumentar el tiempo de espera para wait */
        ldr r1,=delayHex
        ldr r1,[r1]

        ldr r0,=deltaDelay
        ldr r0,[r0]

        add r1,r1,r0

        ldr r5,=delayHex @Aqui es donde se pasa lo de r5 y r10 
        str r1,[r5]

		/* Mover a r10 un contador para que dé la vuelta completa */
		mov r10, #500
		/* Cargar en r5 el delayHex para extablecer la velocidad */
		ldr r5, =delayHex
		ldr r5, [r5]

        bl clockWise

        b solicitud

    invertir:
		/* Mover a r10 un contador para que dé la vuelta completa */
		mov r10, #500
		/* Cargar en r5 el delayHex para extablecer la velocidad */
		ldr r5, =delayHex
		ldr r5, [r5]
        
		bl counterClockWise

        b solicitud

    salir:
		/* Regresar a ingreso de datos */
        b dataInput

teclado:
    ldr r1,=opcion
    ldr r1,[r1]
    cmp r1,#2 /* Validacion de que esta es la opcion 2 */

    bne salida /* De lo contrario sale del sistema (opcion 3) */

    ldr r0,=menu_opciones_txt /*Muestra menu de ingreso por teclado */
    bl puts


	ldr r0, =formatoIngreso
	ldr r1, =eleccion
    bl scanf

    ldr r1,=eleccion /* Obtener eleccion del usuario */
    ldr r1,[r1]
    cmp r1,#1
	beq uno
    bne dos 

    uno: /* Aumentar la velocidad del motor */
		ldr r1,=eleccion
        ldr r1,[r1]
        cmp r1,#1
        bne dos

        ldr r1,=delayHex
        ldr r1,[r1]

        ldr r0,=deltaDelay
        ldr r0,[r0]

        sub r1,r1,r0

        ldr r5,=delayHex @Aqui es donde se pasa lo de r5 y r10 
        str r1,[r5]

		/* Mover a r10 un contador para que dé la vuelta completa */
		mov r10, #500
		/* Cargar en r5 el delayHex para extablecer la velocidad */
		ldr r5, =delayHex
		ldr r5, [r5]

        bl clockWise

        b teclado

    dos: /* Disminuir la velocidad del motor */
        ldr r1,=eleccion
        ldr r1,[r1]
        cmp r1,#2
        bne tres

        ldr r1,=delayHex
        ldr r1,[r1]

        ldr r0,=deltaDelay
        ldr r0,[r0]

        add r1,r1,r0

        ldr r5,=delayHex @Aqui es donde se pasa lo de r5 y r10 
        str r1,[r5]
		
		/* Mover a r10 un contador para que dé la vuelta completa */
		mov r10, #500
		/* Cargar en r5 el delayHex para extablecer la velocidad */
		ldr r5, =delayHex
		ldr r5, [r5]

        bl clockWise

        b teclado

    tres: /* Cambiar de direccion */
		ldr r1,=eleccion
        ldr r1,[r1]
        cmp r1,#3
        bne cuatro
        /* Mover a r10 un contador para que dé la vuelta completa */
		mov r10, #500
		/* Cargar en r5 el delayHex para extablecer la velocidad */
		ldr r5, =delayHex
		ldr r5, [r5]

        bl counterClockWise

        b teclado

    cuatro:
        ldr r1,=eleccion
        ldr r1,[r1]
        cmp r1,#4

        bne errorIngresoTeclado

        b dataInput

salida:
    ldr r1,=opcion
    ldr r1,[r1]
    cmp r1,#3

    bne errorIngreso

	ldr r0, =outro
	bl puts
    mov r7,#1
    swi 0

errorIngreso:
	/* Mostrar mensaje de error de ingreso y regresar a menu principal */
    ldr r0,=error_ingreso_txt
    bl puts 

    b dataInput

errorIngresoTeclado:
	/* Mostrar mensaje de error de ingreso y regresar a menu de ingreso mediante teclado */
    ldr r0,=error_ingreso_txt
    bl puts

    b teclado

@-------------------------------------------------------------------
@ Makes the stepper go counterClockWise
@ params:
@ r5 -> Hexadecimal value to use in bl wait
@ r10-> decimal value to use as a counter to complete one cycle of the stepper
@--------------------------------------------------------------------
counterClockWise:
    /* enciendo 14 y15  */
    mov r0,#14	@instrucciones para encender GPIO 14
	mov r1,#1
	bl SetGpio

    mov r0,#15	@instrucciones para encender GPIO 15
	mov r1,#1
	bl SetGpio


	bl wait
        
    /* apago 14 y 15*/
    mov r0,#14	@instrucciones para apagar GPIO 14
	mov r1,#0
	bl SetGpio

    mov r0,#15	@instrucciones para apagar GPIO 15
	mov r1,#0
	bl SetGpio


    /* enciendo 15 y 23 */
    mov r0,#15	@instrucciones para encender GPIO 15
	mov r1,#1
	bl SetGpio

    mov r0,#23	@instrucciones para encender GPIO 23
	mov r1,#1
	bl SetGpio

	bl wait

    /* apago 15 y 23 */
    mov r0,#15	@instrucciones para apagar GPIO 15
	mov r1,#0
	bl SetGpio

    mov r0,#23	@instrucciones para apagar GPIO 23
	mov r1,#0
	bl SetGpio

    /* enciendo 23 y 24 */
    mov r0,#23	@instrucciones para encender GPIO 23
	mov r1,#1
	bl SetGpio

    mov r0,#24	@instrucciones para encender GPIO 24
	mov r1,#1
	bl SetGpio

	bl wait

	/* apago 23 y 24 */
    mov r0,#23	@instrucciones para apagar GPIO 23
	mov r1,#0
	bl SetGpio

    mov r0,#24	@instrucciones para apagar GPIO 24
	mov r1,#0
	bl SetGpio

	/* enciendo 24 y 14 */
    mov r0,#24	@instrucciones para encender GPIO 24
	mov r1,#1
	bl SetGpio

    mov r0,#14	@instrucciones para encender GPIO 14
	mov r1,#1
	bl SetGpio

	bl wait

	/* apago 24 y 14 */
    mov r0,#24	@instrucciones para apagar GPIO 24
	mov r1,#0
	bl SetGpio

    mov r0,#14	@instrucciones para apagar GPIO 14
	mov r1,#0
	bl SetGpio

	subs r10,#1
	
	bgt counterClockWise

	ldr r1,=opcion
    ldr r1,[r1]
    cmple r1,#2 /* Validacion de que esta es la opcion 2 */
	beq teclado
	bne botones
	mov pc, lr

@-------------------------------------------------------------------
@ Makes the stepper go clockWise direction
@ params:
@ r5 -> Hexadecimal value to use in bl wait
@ r10-> decimal value to use as a counter to complete one cycle of the stepper
@--------------------------------------------------------------------
clockWise:
	/* enciendo 14 y 24  */
	mov r0,#14	@instrucciones para encender GPIO 14
	mov r1,#1
	bl SetGpio

    mov r0,#24	@instrucciones para encender GPIO 24
	mov r1,#1
	bl SetGpio

	bl wait
        
    /* apago 14 y 24*/
    mov r0,#14	@instrucciones para apagar GPIO 14
	mov r1,#0
	bl SetGpio

    mov r0,#24	@instrucciones para apagar GPIO 24
	mov r1,#0
	bl SetGpio


    /* enciendo 24 y 23 */
    mov r0,#24	@instrucciones para encender GPIO 24
	mov r1,#1
	bl SetGpio

    mov r0,#23	@instrucciones para encender GPIO 23
	mov r1,#1
	bl SetGpio

	bl wait

    /* apago 24 y 23 */
    mov r0,#24	@instrucciones para apagar GPIO 24
	mov r1,#0
	bl SetGpio

    mov r0,#23	@instrucciones para apagar GPIO 23
	mov r1,#0
	bl SetGpio

    /* enciendo 23 y 15 */
    mov r0,#23	@instrucciones para encender GPIO 23
	mov r1,#1
	bl SetGpio

    mov r0,#15	@instrucciones para encender GPIO 15
	mov r1,#1
	bl SetGpio

	bl wait

	/* apago 23 y 24 */
    mov r0,#23	@instrucciones para encender GPIO 23
	mov r1,#0
	bl SetGpio

    mov r0,#15	@instrucciones para encender GPIO 15
	mov r1,#0
	bl SetGpio

	/* enciendo 15 y 14 */
    mov r0,#15	@instrucciones para encender GPIO 15
	mov r1,#1
	bl SetGpio

    mov r0,#14	@instrucciones para encender GPIO 14
	mov r1,#1
	bl SetGpio

	bl wait

	/* apago 15 y 14 */
    mov r0,#15	@instrucciones para encender GPIO 1
	mov r1,#0
	bl SetGpio

    mov r0,#14	@instrucciones para encender GPIO 17
	mov r1,#0
	bl SetGpio

	subs r10,#1
	bgt clockWise

	ldr r1,=opcion
    ldr r1,[r1]
    cmple r1,#2 /* Validacion de que debe regresar a la opcion 2 */
	beq teclado
	bne botones

	mov pc, lr


	
@ brief pause routine
wait:
 mov r0, r5 @ big number
sleepLoop:
 subs r0,#1
 bne sleepLoop @ loop delay
 mov pc,lr


/* Inicia parte de datos */
.data 
.align 2
delayHex:
	.word 0x1200000
deltaDelay:
	.word 0x300000
formatoIngreso:
    .asciz "%d"
timeout:
	.word 0
menu_txt:
    .ascii "\033[36mMENU DE INICIO\n-------------------------\n1. Controlar por hardware (botones)\n2. Controlar por software (teclado)\n3. Salir\033[0m\000"
menu_opciones_txt:
    .ascii "\033[36m\nIngrese una de las siguientes opciones\n1. Aumentar velocidad de rotacion\n2. Disminuir velocidad de rotacion\n3. Cambiar sentido de rotacion\n4. Regresar a menu principal\033[0m\000"
error_ingreso_txt:
    .asciz "Elija una opcion correcta"
opcion:
    .word 0
eleccion:
    .word 0
menu_opciones_botones:
	.ascii "\033[36mOprima uno de los siguientes botones\n1. Aumentar velocidad de rotacion\n2. Disminuir velocidad de rotacion\n3. Cambiar sentido de rotacion\n4. Regresar a menu principal\033[0m\000"
outro: .ascii "\033[32m\nMade by Gerardo Mendez & Luis Urbina\033[0m\000"
.global myloc
myloc: .word 0
 .end
