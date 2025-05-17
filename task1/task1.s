; sum_word_cstream

; Input: stream of word (32 bit) in С-string style (end with 0).
; Need to sum all numbers and send result in two words (64 bits).

    .data

input_addr:      .word  0x80
output_addr:     .word  0x84

sum_low:         .word  0
sum_high:        .word  0
temp:            .word  0
of_out:          .word  0xCCCCCCCC         ; Значение для вывода при переполнении
one:             .word  1

    .text
_start:
loop:
    load_ind     input_addr                  ; acc = mem[input_addr]
    beqz         end                         ; если 0 (конец потока), переходим к завершению программы
    store_addr   temp
    add          sum_low                     ; Добавляем к аккумулятору значение sum_low
    store_addr   sum_low                     

    load_addr    temp
    bgt          positive                    ; Если значение > 0, переходим на positive
    beqz         positive                    ; Если значение = 0, тоже переходим на positive
    bvc          loop                        ; Если нет переполнения (V=0), продолжаем цикл
positive:
    bcc          loop                        ; Если нет переноса (C=0), продолжаем цикл
    load_addr    sum_high
    add          one
    bvs          overflow                    ; Если произошло переполнение (V=1), переходим на overflow
    store_addr   sum_high
    jmp          loop
end:
    ; Вывод результата (64-битная сумма)
    load_addr    sum_high                    ; Загружаем старшую часть суммы
    store_ind    output_addr
    load_addr    sum_low                     ; Загружаем младшую часть суммы
    store_ind    output_addr
    halt
overflow:
    ; Обработка переполнения 64-битной суммы
    load_ind     of_out
    store_ind    output_addr
    load_ind     of_out
    store_ind    output_addr
    halt
