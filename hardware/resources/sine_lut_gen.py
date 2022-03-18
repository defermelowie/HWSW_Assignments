from math import sin, pi

COE_FILE = 'hardware/resources/sine_lut.coe'
RADIX = 2

sines = [int(sin(pi*d/180)*1000000) for d in range(91)]
sines_str = [f'{format(sine, "020b")},\n' for sine in sines]
sines_str[-1] = f'{format(sines[-1], "020b")};'

with open(COE_FILE, 'w') as coe:
    coe.write(f'memory_initialization_radix={RADIX};\n')
    coe.write(f'memory_initialization_vector=\n\n')
    coe.writelines(sines_str)
