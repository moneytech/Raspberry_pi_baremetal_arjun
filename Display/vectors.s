
;@-------------------------------------------------------------------------
;@-------------------------------------------------------------------------


.text 


#include "include/sysconfig.h"

	.globl _start
_start:
    ldr pc,reset_handler
    ldr pc,undefined_handler
    ldr pc,swi_handler
    ldr pc,prefetch_handler
    ldr pc,data_handler
    ldr pc,unused_handler
    ldr pc,irq_handler
    ldr pc,fiq_handler	
reset_handler:      .word reset
undefined_handler:  .word hang
swi_handler:        .word hang
prefetch_handler:   .word abort
data_handler:       .word abort
unused_handler:     .word hang
irq_handler:        .word irq
fiq_handler:        .word hang

reset:
    mov r0,#MEM_KERNEL_START
    mov r1,#0x0000
    ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
    ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
	
	;@ (PSR_ABORT_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD7
    msr cpsr_c,r0
    mov sp,#CORE0_EXCEPTION_STACK

    ;@ (PSR_IRQ_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD2
    msr cpsr_c,r0
    mov sp,#CORE0_IRQ_STACK

    ;@ (PSR_FIQ_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD1
    msr cpsr_c,r0
    mov sp,#CORE0_FIQ_STACK

    ;@ (PSR_SVC_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD3
    msr cpsr_c,r0
    mov sp,#CORE0_CODE_STACK
	
    bl notmain
	
.globl start_secondary_core
start_secondary_core:
	mrc	p15, 0, r1, c0, c0, 5	
	and	r1, r1, #CORES-1		/* get CPU ID */
	add r1 , r1,#1
	mov r2,#CORE_TOTAL_STACK_SIZE 
	mul r3,r1,r2
	add r3, r3, #MEM_STACK_START 	 /*r3 has the top most addr of the stack now */
	
	;@ (PSR_ABORT_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD7
    msr cpsr_c,r0
    mov sp,r3

    ;@ (PSR_IRQ_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD2
    msr cpsr_c,r0
	sub r3,r3,#EXCEPTION_STACK_SIZE
    mov sp,r3

    ;@ (PSR_FIQ_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD1
    msr cpsr_c,r0
	sub r3,r3,#IRQ_STACK_SIZE
    mov sp,r3

    ;@ (PSR_SVC_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD3
    msr cpsr_c,r0
	sub r3,r3,#FIQ_STACK_SIZE
    mov sp,r3
	
    bl sysinit_secondary
	
hang: b hang

.globl PUT32
PUT32:
    str r1,[r0]
    bx lr


.globl GET32
GET32:
    ldr r0,[r0]
    bx lr

.globl dummy
dummy:
    bx lr

.globl enable_irq
enable_irq:
    mrs r0,cpsr
    bic r0,r0,#0x80
    msr cpsr_c,r0
    bx lr
	
.globl enable_fiq
enable_fiq:
    mrs r0,cpsr
    bic r0,r0,#0x40
    msr cpsr_c,r0
    bx lr

.globl BRANCHTO
BRANCHTO:
    bx r0
	
.globl ldrex
ldrex:
	ldrex r0,[r1]
	bx lr

.globl strex
strex:
	strex r0,r1,[r2]
	bx lr
	
.globl enable_L1_cache
enable_L1_cache:	
	mrc p15, 0, r0, c1, c0, 0
	orr r0,r0,#0x00000004
	mcr p15, 0, r0, c1, c0, 0
	bx lr
		
.globl enable_L2_cache
enable_L2_cache:
	mrc p15, 0, r0, c1, c0, 1
	orr r0,r0,#0x00000002
	mcr p15, 0, r0, c1, c0, 1
	bx lr
		
irq:
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
    bl c_irq_handler
    pop  {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
    subs pc,lr,#4
	
abort:
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
    bl data_abort_handler

	
	
	
;@-------------------------------------------------------------------------
;@-------------------------------------------------------------------------

;@-------------------------------------------------------------------------
;@
;@ Copyright (c) 2012 David Welch dwelch@dwelch.com
;@
;@ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;@
;@ The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;@
;@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;@
;@-------------------------------------------------------------------------

