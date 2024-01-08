##### Dépendances #####
# aucune 

##### Constantes #####
n = 300 # taille des matrices carrées multipliées
N = 100 # Nombre de tests

##### Multiplication de matrices carrées (NAIF) #####
AxB <- function(A, B, p = n){
  C <- matrix(0, p, p)
  incr <- 1:p
  
  for (l in incr) { # boucle sur les lignes de A
    for (c in incr) { # boucle sur les colonnes de B
      temp <- 0
      for (k in incr) {
        temp <- temp + A[l,k]*B[k,c]
      }
      C[l,c] <- temp
    }
  }
  
  return(C)
}

##### multiplication de matrices avec outils R #####
AxB2 <- function(A, B){
  C <- A %*% B
  return(C)
}

#####################################################
##### Mesures sur matrices aléatoires U[0,1] ########
#####################################################

##### Algo naif
resultats <- numeric(N)

# N multiplications de matrices aléatoires
for (i in 1:N) {
  A <- matrix(runif(n*n),n,n)
  B <- matrix(runif(n*n),n,n)
  
  start_time <- Sys.time()
  D <- AxB(A,B)
  end_time <- Sys.time()
  
  resultats[i] <- end_time - start_time
  # print(i)
}

# print(resultats)
print(paste0("moyenne (algo naif): ", mean(resultats)))
print(paste0("sd (algo naif): ", sd(resultats)))

##### Algo avec outils
resultats2 <- numeric(N*10)

for (i in 1:(N*10)) {
  A <- matrix(runif(n*n),n,n)
  B <- matrix(runif(n*n),n,n)
  
  start_time <- Sys.time()
  D <- AxB2(A,B)
  end_time <- Sys.time()
  
  resultats2[i] <- end_time - start_time
  # print(i)
}

# print(resultats2)
print(paste0("moyenne (avec %*%): ", mean(resultats2)))
print(paste0("sd (avec %*%): ", sd(resultats2)))





