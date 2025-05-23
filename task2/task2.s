\ capital_case_pstr
\ Convert the first character of each word in a Pascal string to capital case.
\    Capital Case Is Something Like This.
\    - Result string should be represented as a correct Pascal string.
\    - Buffer size for the message -- `0x20`, starts from `0x00`.
\    - End of input -- new line.
\    - Initial buffer values -- `_`.
\    Python example args:
\        s (str): The input string till new line.
\    Returns:
\        tuple: A tuple containing the capitalized output string and input rest.

    .data
len:             .byte  0                  \ Длина результирующей строки
buf:             .byte  '_______________________________' \ Буфер на 32 символа
padding:         .byte  '___'              \ Дополнительное выравнивание
flag:            .word  1                  \ Флаг состояния (1 - следующую букву сделать заглавной)
input_addr:      .word  0x80
output_addr:     .word  0x84
mask:            .byte  0, '___'           \ Маска для преобразования регистра (0 + 3 байта заполнителя)
of_out:          .word  0xCCCCCCCC         \ Значение для заполнения при ошибке

    .text

    .org 0x90                \ Установка начального адреса кода
_start:
    @p input_addr b!         \ b = input_addr Загрузка адреса ввода в регистр b
    lit buf a!               \ a = buf Загрузка адреса буфера в a
    capcase                  \ Вызов подпрограммы обработки

    @p output_addr b!        \ b = output_addr Загружаем адрес вывода в b
    lit len a!               \ a = len (длина полученной строки) Загружаем адрес длины строки в a
    @+ lit 255 and           \ Читаем длину и маскируем до 8 бит

    print                    \ Вывод результата
    halt

    \ Обратботка каждого символа, пока не встретим '\n'
capcase:
    @b lit 255 and dup       \ Читаем символ из b, маскируем до 8 бит, копируем (строки состоят из 8-ми битных символов, поэтому нам нужны только младшие 8)
    lit -10 + if end         \ Если символ равен '\n' (10), завершаем
    dup lit -97 + -if char_ab97 \ Если символ >= 'a' (97), проверяем дальше

    dup lit -65 + -if char_ab65 \ Если символ >= 'A' (65), проверяем дальше
    shit_char ;              \ Иначе пропускаем

    \ Обработка заглавных букв (A-Z)
char_ab65:
    dup lit -90 + -if shit_char \ Если символ > 'Z' (90), пропускаем
    upcase_char ;            \ Иначе обрабатываем как заглавную

shit_char:
    set_flag_1               \ Устанавливаем flag = 1 (следующий символ - заглавный)
    write_char               \ Записываем символ в буфер
    capcase ;                \ Рекурсивно продолжаем обработку

    \ Обработка строчных букв (a-z)
char_ab97:
    dup lit -122 + -if shit_char \ Если символ > 'z' (122), пропускаем
    downcase_char ;          \ Иначе обрабатываем как строчную

    \ Преобразование в строчную
downcase_char:
    @p flag                  \ Загружаем значение flag
    lit -1 + if do_upcase    \ Если flag != 1, переходим к do_upcase

    write_char               \ Записываем символ в буфер
    capcase ;                \ Рекурсивно продолжаем обработку

upcase_char:
    @p flag                  \ Проверяем флаг
    lit -1 + if write_without_downcase \ Если flag != 1, записываем без изменений
    do_downcase ;            \ Иначе переходим к do_downcase
write_without_downcase:
    write_char               \ Записываем символ в буфер
    lit 0 !p flag            \ Устанавливаем flag = 0
    capcase ;                \ Рекурсивно продолжаем обработку

do_upcase:
    dup lit -32 +            \ Преобразуем строчную букву в заглавную (вычитаем 32)
    write_char               \ Записываем символ в буфер
    lit 0 !p flag            \ Устанавливаем flag = 0
    capcase ;                \ Рекурсивно продолжаем обработку

do_downcase:
    dup lit 32 +             \ Преобразуем заглавную букву в строчную (прибавляем 32)
    write_char               \ Записываем символ в буфер
    lit 0 !p flag            \ Устанавливаем flag = 0
    capcase ;                \ Рекурсивно продолжаем обработку

    \ Запись символа в буфер
write_char:
    @p mask +                \ Добавляем смещение маски (не используется явно)
    !+                       \ Сохраняем символ по адресу в A и увеличиваем A
    @p len                   \ Загружаем текущую длину строки
    lit 1 +                  \ Увеличиваем длину на 1
    dup                      \ Дублируем новое значение длины
    !p len                   \ Сохраняем новое значение длины
    lit 255 and              \ Маскируем до 8 бит
    lit -32 + if err         \ Если длина превысила 32, переходим к err
    ;                        \ Возврат из подпрограммы

    \ Обработка ошибок
err:
    @p of_out                \ Загружаем значение ошибки
    @p output_addr b!        \ Загружаем адрес вывода в B
    !b                       \ Записываем значение ошибки по адресу в B
    halt                     \ Завершаем программ
end:
    drop                     \ Удаляем значение с вершины стека
    ;                        \ Возврат из подпрограммы

    \ Вывод результата
print:
    dup if end_print         \ Если длина строки = 0, переходим к end_print
    lit -1 +                 \ Уменьшаем счетчик длины на 1
    @+ lit 255 and           \ Читаем следующий символ из буфера
    !b                       \ Записываем символ по адресу в B
    print ;                  \ Рекурсивно продолжаем вывод
end_print:
    drop                     \ Удаляем значение с вершины стека
    ;                        \ Возврат из подпрограммы

    \ Установка флага
set_flag_1:
    lit 1 !p flag            \ Устанавливаем flag = 1
    ;
