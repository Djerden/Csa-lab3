def capital_case_pstr(s):
    """Convert the first character of each word in a Pascal string to capital case.

    Capital Case Is Something Like This.

    - Result string should be represented as a correct Pascal string.
    - Buffer size for the message -- `0x20`, starts from `0x00`.
    - End of input -- new line.
    - Initial buffer values -- `_`.

    Python example args:
        s (str): The input string till new line.

    Returns:
        tuple: A tuple containing the capitalized output string and input rest.
    """
    line, rest = read_line(s, 0x20)
    if line is None:
        return [overflow_error_value], rest
    return line.title(), rest

print(capital_case_pstr('hello world!\n'))

