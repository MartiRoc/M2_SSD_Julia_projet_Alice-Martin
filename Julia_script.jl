##### Dépendances #####
using Random
using Statistics

##### Constantes #####
const n = 300  # taille des matrices carrées multipliées
const N = 100  # Nombre de tests

##### Multiplication de matrices carrées (NAIF) #####
function AxB(A, B, p=n)
    C = zeros(p, p)
    incr = 1:p

    for l in incr  # boucle sur les lignes de A
        for c in incr  # boucle sur les colonnes de B
            temp = 0
            for k in incr
                temp += A[l, k] * B[k, c]
            C[l, c] = temp
            end
        end
    end

    return C
end

##### multiplication de matrices avec outils Julia #####
function AxB2(A, B)
    C = A * B
    return C
end

#####################################################
##### Mesures sur matrices aléatoires U[0,1] ########
#####################################################

##### Algo naif
resultats = zeros(N)

# N multiplications de matrices aléatoires
for i in 1:N
    A = rand(n, n)
    B = rand(n, n)

    start_time = time()
    D = AxB(A, B)
    end_time = time()

    resultats[i] = end_time - start_time
    #println(i)
end

#println(resultats)
println("\n moyenne (algo naif): ", sum(resultats)/N)
println("\n sd (algo naif): ", std(resultats))


##### Algo avec outils Julia
resultats2 = zeros(N * 10)

for i in 1:N * 10
    A = rand(n, n)
    B = rand(n, n)

    start_time = time()
    D = AxB2(A, B)
    end_time = time()

    resultats2[i] = end_time - start_time
    #println(i)
end

#println("\n", resultats2)
println("\n moyenne : ", sum(resultats2)/(N*10))
println("\n sd : ", std(resultats2))