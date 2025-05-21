; sum_word_cstream

    .data

input_addr:      .word  0x80
output_addr:     .word  0x84

sum_low:         .word  0
sum_high:        .word  0
temp:            .word  0
of_out:          .word  0xCCCCCCCC
one:             .word  1

    .text
_start:
loop:
    load_ind     input_addr
    beqz         end
    
    store_addr   temp
    add          sum_low
    store_addr   sum_low                     

    load_addr    temp
    bgt          positive
    beqz         positive
    bvc          loop
positive:
    bcc          loop
    load_addr    sum_high
    add          one
    bvs          overflow
    store_addr   sum_high
    jmp          loop
end:
    load_addr    sum_high
    store_ind    output_addr
    load_addr    sum_low
    store_ind    output_addr
    halt
overflow:
    load_ind     of_out
    store_ind    output_addr
    load_ind     of_out
    store_ind    output_addr
    halt
