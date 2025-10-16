primerNumero = float(input("Ingrese el primer número(Si es decimal debe ir separado por un '.' ej. '1.5') ): "))
simbolo = input("Ingrese el símbolo de la operación (+, -, *, /): ")
segundoNumero = float(input("Ingrese el segundo número(Si es decimal debe ir separado por un '.' ej. '1.5'): "))

if simbolo == "+":
    resultado = primerNumero + segundoNumero
    print(f"El resultado de la suma es: {resultado}")
elif simbolo == "-":
    resultado = primerNumero - segundoNumero
    print(f"El resultado de la resta es: {resultado}")
elif simbolo == "*":
    resultado = primerNumero * segundoNumero
    print(f"El resultado de la multiplicación es: {resultado}")
elif simbolo == "/":
    if segundoNumero != 0:
        resultado = primerNumero / segundoNumero
        print(f"El resultado de la división es: {resultado}")
    else:
        print("Error: No se puede dividir por cero.")
else:
    print("Error: Símbolo de operación no válido.")
# Calculadora básica que realiza operaciones aritméticas simples