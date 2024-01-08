##### Dépendances #####
import random
import time
import numpy as np

##### Constantes #####
n = 300  # taille des matrices carrées multipliées
N = 100  # Nombre de tests

##### Multiplication de matrices carrées (NAIF) #####
def AxB(A, B, p=n):
    C = [[0] * p for _ in range(p)]
    incr = list(range(1, p + 1))

    for l in incr:  # boucle sur les lignes de A
        for c in incr:  # boucle sur les colonnes de B
            temp = 0
            for k in incr:
                temp += A[l - 1][k - 1] * B[k - 1][c - 1]
            C[l - 1][c - 1] = temp

    return C

##### multiplication de matrices avec outils Python #####
def AxB2(A, B):
    C = np.dot(A, B)
    return C.tolist()

#####################################################
##### Mesures sur matrices aléatoires U[0,1] ########
#####################################################

##### Algo naif
resultats = [0] * N

# N multiplications de matrices aléatoires
for i in range(1, N + 1):
    A = [[random.random() for _ in range(n)] for _ in range(n)]
    B = [[random.random() for _ in range(n)] for _ in range(n)]

    start_time = time.time()
    D = AxB(A, B)
    end_time = time.time()

    resultats[i - 1] = end_time - start_time
    #print(i)

#print(resultats)
print("\nmoyenne (algo naif):", np.mean(resultats))
print("\nsd (algo naif):", np.std(resultats))

##### Algo avec outils Python
resultats2 = [0] * (N * 10)

for i in range(1, (N * 10) + 1):
    A = [[random.random() for _ in range(n)] for _ in range(n)]
    B = [[random.random() for _ in range(n)] for _ in range(n)]

    A = np.array(A)
    B = np.array(B)

    start_time = time.time()
    D = AxB2(A, B)
    end_time = time.time()

    resultats2[i - 1] = end_time - start_time
    #print(i)

#print("\n", resultats2)
print("\nmoyenne (avec numpy):", np.mean(resultats2))
print("\nsd (avec numpy):", np.std(resultats2))


