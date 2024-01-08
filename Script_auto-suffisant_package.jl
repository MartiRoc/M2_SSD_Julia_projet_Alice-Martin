########## Version

# Julia 1.10

########## Dépendances 

using Pkg
Pkg.add("DataFrames")
Pkg.add("Plots")

using DataFrames
using Plots

############################
##### DONNEES FICTIVES #####
############################

#= Les données ci-dessous représentent les temps de survie (<jours>) de deux groupes de patients (<traitement>) à une maladie. 
Nous disposons d'une information supplémentaire : la fonction rénale (<fonction>) ayant possiblement une influence sur la survie.
La modalité "N" de cette dernière variable désigne une fonction rénale normale, "A" une fonction rénale anormale. La variable 
<statut> indique si le temps de survie est censuré ou non, i.e si le patient est mort de la maladie ou si il a quitté l'étude 
d'une autre facon. =#

df_test = DataFrame(
    duree = [8,8,13,18,23,52,63,63,70,76,180,195,210,220,365,632,700,852,1296,1296,1328,1460,1976,1990,2240],
    statut = [repeat([1],14);[0,1,1,0,1];repeat([0],6)],
    traitement = [1,1,2,2,2,1,1,1,2,2,2,2,2,1,1,2,2,1,2,1,1,1,1,2,2],
    fonction = [["A", "N"];repeat(["A"],6);repeat(["N"],17)]
)

#####################
##### FONCTIONS #####
#####################

##### Estimateur de Kaplan-Meier

#= entrées : 
En entrée, time encode les temps de survie, status indique la censure ou non du temps de survie 
(0 → censure, 1 → non-censure) et group est un argument facultatif qui encode l'appartenance à 
des groupes des arguments précédents. Dans le cas où ce dernier argument est renseigné la fonction 
calcule autant d'estimateurs de Kaplan-Meier qu'il y a de facteurs (groupes) dans le vecteur group. 
Tous les arguments (le facultatif s'il est renseigné) doivent posséder la même dimension.
=#

#= sorties : 
En sortie on obtient une DataFrame à deux colonnes temps & S_KM. Si des groupes sont renseignés dans 
la variable group la fonction retourne un tuple nommé : .a, .b, .c, ... , où chaque élément est une 
DataFrame temps & S_KM pour chacun des facteurs de la variable group (l'équivalence .a, .b, ... <--> 
facteur1, facteur2, ... est affichée à l'appel de la fonction).
=#

function KM(time, status, group = nothing)
    
    data = DataFrame(duree = time, statut = status, groupe = group)
    sort!(data, :duree)

    if isnothing(group)
        S_KM = [1.0]  # va contenir les estimations aux temps t_i (t_0 OK car = 1)
        i = 1  # incrément des temps
        temps = unique(data.duree)  # t_1, t_2, ..., t_n
        N = length(data.duree)  # total d'individus

        # boucle sur les temps
        for j in 1:length(temps)
            # nb de décès à t_i
            d_j = length(data[(data.duree .== temps[j]) .& (data.statut .== 1), 1])
            # nb d'ind à risque juste avant t_i
            R_j = N - length(data[(data.duree .< temps[j]), 1])
            # S_KM(t_i) par récurrence
            push!(S_KM, (1 - (d_j / R_j)) * S_KM[j])
        end

        temps = [0; temps]
        return df_resultat = DataFrame(temps=temps, S_KM=S_KM)

    else 
        facteurs = unique(data.groupe)
        n = length(facteurs)
        resultats = []


        for j in facteurs
            data_temp = data[data.groupe .== j, : ]
            S_KM_j = KM(data_temp.duree, data_temp.statut)
            resultats = [resultats ; [S_KM_j]]
        end

        symbols_tuple_sortie = Tuple(Symbol.(collect('a':'a'+(n-1))))
        res = NamedTuple{symbols_tuple_sortie}(resultats)
        println("\nTuple de sortie $symbols_tuple_sortie <--> groupes $facteurs \n")

        return res

    end

end

##### Test du Log-Rank (Mantel-Haenszel test → sans pondération)

#= entrées : 
En entrée, times, status et group sont équivalents aux arguments à renseigner pour la fonction KM 
ci-dessus. Cependant, cette fois group est un argument obligatoire et doit être binaire. La dernière 
variable approx-pval est liée à l'approximation réalisée par la fonction dans le calcul de la p-valeur.
=#

#= sorties : 
En sortie on obtient un tuple nommé : .T, .pval avec resp. la statistique de test et la p-valeur approchée.
=#

function Log_Rank(times, status, group, approx_pval = 1000000)

    data = DataFrame(duree = times, statut = status, groupes = group)
    sort!(data, :duree)
    
    g1 = unique(data.groupes)[1]  # facteur groupe 1
    g2 = unique(data.groupes)[2]  # facteur groupe 2

    R_i_1 = length(data[data.groupes .== g1, 1])  # nb sujets à risque au temps 0 grp1
    R_i_2 = length(data[data.groupes .== g2, 1])  # nb sujets à risque au temps 0 grp2
    T_i = unique(data.duree)  # toutes les durées d’intérêt groupes confondus
    U = []  # partie de la statistique de test (numérateur)
    V = []  # partie de la statistique de test (dénominateur)

    for i in 1:length(T_i)
        ##### Grandeurs groupe 2 #####
        
        # décès au temps i
        d_i_2 = length(data[(data.duree .== T_i[i]) .& (data.groupes .== g2) .& (data.statut .== 1), 1])
        # censures au temps i
        c_i_2 = length(data[(data.duree .== T_i[i]) .& (data.groupes .== g2) .& (data.statut .== 0), 1])
        
        ##### Grandeurs groupe 1 #####
        
        # décès au temps i
        d_i_1 = length(data[(data.duree .== T_i[i]) .& (data.groupes .== g1) .& (data.statut .== 1), 1])
        # censures au temps i 
        c_i_1 = length(data[(data.duree .== T_i[i]) .& (data.groupes .== g1) .& (data.statut .== 0), 1])
        # décès attendus au temps i
        e_i_1 = (R_i_1 / (R_i_1 + R_i_2)) * (d_i_1 + d_i_2)
        
        ##### Pour la statistique de test #####
        
        # Pour le numérateur de la statistique de test
        push!(U, d_i_1 - e_i_1)
        # Pour le dénominateur de la statistique de test
        d_i = d_i_1 + d_i_2
        R_i = R_i_1 + R_i_2
        push!(V, d_i * ((R_i - d_i) / (R_i - 1)) * ((R_i_1 * R_i_2) / (R_i^2)))
        
        ##### Actualisation des sujets exposés au risque #####
        R_i_1 -= d_i_1 + c_i_1
        R_i_2 -= d_i_2 + c_i_2
    end

    ##### Statistique de test #####
    U = sum(U)
    V = filter(!isnan, V)
    V = sum(V)
    stat_T = (U^2) / V

    ##### p-valeur #####
    # Approximation CCDF de Chi2_1 : pval = P(chi2_1 > stat_T)
    pval = sum((randn(approx_pval).^2) .> stat_T)/approx_pval

    ##### Résultat #####

    res = NamedTuple{(:T, :pval)}([stat_T, pval])

    return res

end

##### Test de la fonction 
# res = Log_Rank(df_test.duree, df_test.statut, df_test.fonction)