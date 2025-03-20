def main():
    a1 = 2**16-4
    print("a1 ", a1)

    b1 = 2**16-1
    print("b1 ", b1)

    c1 = 2**32-5
    print("c1 ", c1)

    d1 = 2**32-4
    print("d1 ", d1)

    e1 = 2**32-1
    print("e1 ", e1)

    part11 = (d1 * a1) // (a1 + b1 * c1)
    print("part1: ", part11)   
    print("делимое ", d1 * a1)
    print("делитель ", a1 + b1 * c1)

    part21 = (d1 + b1) // (e1 - a1)
    print("part2 ", part21)
    print("делимое2 ", d1 + b1)
    print("делитель2 ", e1 - a1)

    result1 = part11 + part21
    print("Результат при боьших: ", result1)
 
'''
    a = int(input("Введите a: "))
    b = int(input("Введите b: "))
    c = int(input("Введите c: "))
    d = int(input("Введите d: "))
    e = int(input("Введите e: "))
    
    part1 = (d * a) // (a + b * c)
    
    part2 = (d + b) // (e - a)
    
    result = part1 + part2
    
    print("Результат:", result)
'''
if __name__ == "__main__":
    main()

