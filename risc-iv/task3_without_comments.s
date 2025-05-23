    .data

input_addr:      .word  0x80
output_addr:     .word  0x84

    .text
    .org 0x88
_start:
    jal ra, init_stack
    jal ra, do_task
    halt

init_stack:
    addi      sp, zero, 0x500
    jr        ra

do_task:
    addi      sp, sp, -4
    sw        ra, 0(sp)
    lui t0, %hi(input_addr)
    addi t0, t0, %lo(input_addr)
    lw t1, 0(t0)
    lw a0, 0(t1)

    jal ra, big_to_little_endian

    lui t0, %hi(output_addr)
    addi t0, t0, %lo(output_addr)
    lw t1, 0(t0)
    sw a0, 0(t1)
    lw        ra, 0(sp)
    addi      sp, sp, 4
    jr        ra


big_to_little_endian:
    addi t5, zero, 0xFF

    mv t0, a0
    addi a0, zero, 0
    addi t1, zero, 0
    addi t2, zero, 4

byte_swap_loop:
    beq t1, t2, byte_swap_done
    
    and t3, t0, t5
    
    addi t6, zero, 3       
    sub t6, t6, t1
    addi t4, zero, 8
    mul t6, t6, t4
    
    sll t3, t3, t6
    or a0, a0, t3
    
    addi t6, zero, 8
    srl t0, t0, t6
    addi t1, t1, 1
    j byte_swap_loop

byte_swap_done:
    jr ra