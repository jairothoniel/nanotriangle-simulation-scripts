import numpy as np

def leer_poscar(nombre_archivo):
    with open(nombre_archivo, 'r') as f:
        lineas = f.readlines()
    
    # Leer encabezado
    encabezado = lineas[:8]

    # Leer vectores de celda
    escala = float(encabezado[1].strip())
    vectores_celda = np.array([list(map(float, linea.split())) for linea in encabezado[2:5]])

    # Leer tipos de átomos y cantidades
    elementos = encabezado[5].split()
    cantidades = list(map(int, encabezado[6].split()))

    # Leer coordenadas de átomos
    coordenadas = np.array([list(map(float, linea.split())) for linea in lineas[8:]])

    return encabezado, vectores_celda, elementos, cantidades, coordenadas

def centrar_nanotriangulo(vectores_celda, coordenadas):
    # Calcular los límites de la celda en cada dirección
    limites_celda = np.array([vectores_celda[i][i] for i in range(3)])

    # Calcular el centro geométrico del nanotriángulo
    centro_geom = np.mean(coordenadas, axis=0)

    # Calcular el desplazamiento necesario para centrar el nanotriángulo
    desplazamiento = 0.5 - centro_geom

    # Aplicar el desplazamiento a todas las coordenadas
    coordenadas_centradas = coordenadas + desplazamiento

    # Asegurarse de que las coordenadas estén dentro de [0, 1]
    coordenadas_centradas = coordenadas_centradas % 1.0

    return coordenadas_centradas

def escribir_poscar(nombre_archivo, encabezado, coordenadas_centradas):
    with open(nombre_archivo, 'w') as f:
        # Escribir el encabezado
        f.writelines(encabezado[:8])

        # Escribir las coordenadas centradas
        for coord in coordenadas_centradas:
            f.write("  {: .16f}  {: .16f}  {: .16f}\n".format(*coord))

def centrar_poscar(nombre_archivo_entrada, nombre_archivo_salida):
    encabezado, vectores_celda, elementos, cantidades, coordenadas = leer_poscar(nombre_archivo_entrada)
    coordenadas_centradas = centrar_nanotriangulo(vectores_celda, coordenadas)
    escribir_poscar(nombre_archivo_salida, encabezado, coordenadas_centradas)
    print(f"El archivo POSCAR centrado ha sido guardado como {nombre_archivo_salida}")

# Uso del script
nombre_archivo_entrada = 'POSCAR'
nombre_archivo_salida = 'POSCAR_centrado'
centrar_poscar(nombre_archivo_entrada, nombre_archivo_salida)
