; big_to_little_endian
; Convert a 32-bit integer from big-endian to little-endian format

    .data

input_addr:      .word  0x80
output_addr:     .word  0x84

    .text
_start:
    lui      t0, %hi(input_addr)             ; Загружаем старшие 20 бит адреса input_addr
    addi     t0, t0, %lo(input_addr)         ; Добавляем младшие 12 бит адреса
    lw       t1, 0(t0)                       ; t1 = 0x80 Загружаем значение из памяти (0x80) в t1
    lw       a0, 0(t1)                       ; a0 = inp val Загружаем значение по адресу 0x80 в a0 (входное значение)
    
    ; Вызов функции преобразования:
    jal      ra, big_to_little_endian        ; Переход к функции, сохраняя адрес возврата в ra

    ; Сохранение результата по адресу output_addr:
    lui      t0, %hi(output_addr)            ; Загружаем старшие 20 бит адреса output_addr
    addi     t0, t0, %lo(output_addr)        ; Добавляем младшие 12 бит
    lw       t1, 0(t0)                       ; Загружаем значение output_addr (0x84) в t1
    sw       a0, 0(t1)                       ; Сохраняем результат (a0) по адресу 0x84

    halt

; Функция преобразования big-endian в little-endian
big_to_little_endian:
    addi     t5, zero, 0xFF                  ; Загружаем маску 0xFF в t5 (для выделения байтов)

    mv       t0, a0                          ; t0 = original value ; Копируем входное значение из a0 в t0
    addi     a0, zero, 0                     ; Initialize result to 0 ; Инициализируем результат (a0) нулем
    addi     t1, zero, 0                     ; Initialize loop counter ; Инициализируем счетчик цикла (t1) нулем
    addi     t2, zero, 4                     ; Loop 4 times (for 4 bytes) ; Устанавливаем предел цикла - 4 итерации (по байтам)

; Начало цикла обработки байтов
byte_swap_loop:
    beq      t1, t2, byte_swap_done          ; Exit loop when counter reaches 4 ; Если счетчик достиг 4, выходим из цикла

    and      t3, t0, t5                      ; Extract current byte ; Извлекаем текущий байт (младший) с помощью маски 0xFF
    
    ; Вычисляем величину сдвига для текущего байта:
    addi     t6, zero, 3                     ; t6 = 3 (максимальный сдвиг)
    sub      t6, t6, t1                      ; Calculate shift amount (3-i)*8 ; t6 = 3 - i (i - номер текущей итерации)
    addi     t4, zero, 8                     ; t4 = 8 (бит в байте)
    mul      t6, t6, t4                      ; t6 = (3-i)*8 ; t6 = (3-i)*8 (вычисляем сдвиг в битах)

    sll      t3, t3, t6                      ; Shift byte to its new position ; Сдвигаем байт в его новую позицию
    or       a0, a0, t3                      ; Add byte to result ; Добавляем байт к результату

    ; Подготовка к следующей итерации:
    addi     t6, zero, 8                     ; t6 = 8 (для сдвига)
    srl      t0, t0, t6                      ; Shift original value right by 8 bits ; Сдвигаем исходное значение вправо на 8 бит (обрабатываем следующий байт)
    addi     t1, t1, 1                       ; Increment counter ; Увеличиваем счетчик итераций
    j        byte_swap_loop                  ; Переход к началу цикла

; Конец функции
byte_swap_done:
    jr       ra                              ; Возврат из функции по адресу в ra