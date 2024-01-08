///// Dépendances /////
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

///// Constantes /////
#define n 300
#define N 200

///// Multiplication de matrices carrées (NAIF) /////
void AxB(float A[n][n], float B[n][n], float C[n][n]) {
    int l, c, k;

    for (l = 0; l < n; l++) {
        for (c = 0; c < n; c++) {
            C[l][c] = 0;
            for (k = 0; k < n; k++) {
                C[l][c] += A[l][k] * B[k][c];
            }
        }
    }
}

/////////////////////////////////////////////////////
///// Mesures sur matrices aléatoires U[0,1] ////////
/////////////////////////////////////////////////////

///// Algo naif
int main() {

    clock_t start_time, end_time ;
    float resultats[N];

    // N multiplications de matrices aléatoires
    for (int a = 0; a < N; a++) {

        // Génération des matrices carrées(n) A et B aléatoires 
        float A[n][n];
        float B[n][n];
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                // Utilisation de la fonction rand() pour générer un entier aléatoire
                int rand1 = rand();
                int rand2 = rand();
                // Normalisation du nombre pour le ramener dans l'intervalle [0,1]
                double rand1_normalise = (double)rand1 / RAND_MAX;
                double rand2_normalise = (double)rand2 / RAND_MAX;
                // Assignation du nombre normalisé aux matrices A et B
                A[i][j] = rand1_normalise;
                B[i][j] = rand2_normalise;
            }
        }

        // Multiplication
        start_time = clock();
        float C[n][n];
        AxB(A, B, C);
        end_time = clock(); 

        // Récupération du temps d'éxécution
        resultats[a] = ((double) (end_time - start_time)) / CLOCKS_PER_SEC ; 
    }
    

    // Affichages des N temps et de la moyenne 
    double moyenne = 0 ; 

    for (int i = 0; i < N; i++)
    {
        //printf("%f,  ", resultats[i]); 
        moyenne += resultats[i];
    }

    printf("\n\nTaille des matrices aleatoires U(0,1) multipliees naivement : %i \n", n);
    printf("\nMoyenne du temps d'execution : %f sur %i operations \n\n", moyenne / N, N);

    return 0;
}

