    GLOBAL __main
    AREA main, CODE, READONLY
    EXPORT __main
    EXPORT __use_two_region_memory
__use_two_region_memory EQU 0

	

__main
	bl adc_config
	bl led_config
loop
	bl adc_read
	bl led_write
	b  loop

adc_config
	push {lr}
	; Activar reloj de los pines
	ldr r0, =0x4002104C ;RCC_AHB2ENR
	ldr r1, [r0]
	ldr r2, =0x00002001
	orr r1, r2
	str r1, [r0]
	; PA1 en modo analogico
	ldr r0, =0x48000000 ;GPIOA
	ldr r1, [r0] ;MODER
	orr r1, #0x0C
	str r1, [r0]
	ldr r1, [r0, #0x0C] ;PUPDR
	bic r1, #0x0C
	str r1, [r0, #0x0C]

	ldr r0, =0x50000100
	ldr r1, =0x00001008
	str r1, [r0, #0x0C]
	movs r1, #0x80
	str r1, [r0, #0x30]
	ldr r1, =0x000001C0
	str r1, [r0, #0x14]
	ldr r2, =0x50000308
	ldr r1, =0x00030000
	str r1, [r2]
	; Salir de deep power down y activar regulador de ADC
	ldr r1, [r0, #0x08]
	ldr r2, =0x20000000
	bic r1, r2
	ldr r2, =0x10000000
	orr r1, r2
	str r1, [r0, #0x08]
	ldr r1, =2000
	
adc_wait
	subs r1, #1
	cmp r1, #0
	bgt adc_wait

	ldr r1, [r0, #0x08]
	orr r1, #1
	str r1, [r0, #0x08]
	
adc_ready
	ldr r1, [r0] ;ISR
	and r1, #1
	cmp r1, #0
	beq adc_ready
	pop {pc}
	
led_config
	push {lr}
	ldr r0, =0x48000000 ; GPIOA
	ldr r1, [r0]
	ldr r2, =0x0000FC03
	bic r1, r2
	ldr r2, =0x00005401
	orr r1, r2
	str r1, [r0]
	ldr r1, [r0, #0x0C]
	ldr r2, =0x0000FC0F
	bic r1, r2
	str r1, [r0, #0x0C]

	ldr r0, =0x48000018
	ldr r1, =0x00E10000
	str r1, [r0]
	
	pop {pc}

adc_read
	push {lr}
	ldr r1, =0x50000100
	ldr r2, [r1, #0x08]
	orr r2, #4
	str r2, [r1, #0x08]	

adc_wait_eoc
	ldr r2, [r1]
	and r2, #4
	cmp r2, #0
	beq adc_wait_eoc
	ldr r0, [r1, #0x40]
	pop {pc}
	
led_write
	push {lr}
	movs r1, #0
	ldr r2, =205
	cmp r0, r2
	blt led_output
	orr r1, #0x20
	ldr r2, =410
	cmp r0, r2
	blt led_output
	orr r1, #0x40
	ldr r2, =615
	cmp r0, r2
	blt led_output
	orr r1, #0x80
	ldr r2, =820
	cmp r0, r2
	blt led_output
	orr r1, #0x01

led_output
	ldr r2, =0x48000018
	ldr r3, =0x00E10000
	str r3, [r2]
	str r1, [r2]
	
	pop {pc}


	end