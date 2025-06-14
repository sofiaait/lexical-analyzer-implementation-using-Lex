%{
/* PARTIE DECLARATIONS */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/* CODIFICATION TOKENS */
enum TOKEN {FIN=0, PV, IF, THEN, END, ELSE, REPEAT, UNTIL, READ, WRITE, IDENT, OPREL, OPADD, OPMUL, ENTIER, PARG, PARD, AFF};

/* CODIFICATION DES ATTRIBUTS POUR LES TOKENS */
enum CODEOPREL {INF, EGAL};
enum CODEOPADD {PLUS, MOINS};
enum CODEOPMUL {MULT, DIV};

/* Union pour les attributs des tokens */
union Attribut {
    char *nom;
    int valeur;
    enum CODEOPREL coprel;
    enum CODEOPADD copadd;
    enum CODEOPMUL copmul;
} attribut;

/* Fonction pour gérer les erreurs lexicales */



void erreur_lexicale(){
    printf("ligne %d : erreur lexicale, ",yylineno);
    if (isprint(yytext[0]))
     printf("'%c' ",yytext[0]);
    printf("caractere illegal.\n");
    exit(-1);
}


%}



/* Déclarations des règles */
lettre  [A-Za-z]
chiffre [0-9]
ident   {lettre}(_?({lettre}|{chiffre}))*

%%

"if"        { return IF; }
";"         { return PV; }
"("         { return PARG; }
")"         { return PARD; }
"then"      { return THEN; }
"else"      { return ELSE; }
"end"       { return END; }
"repeat"    { return REPEAT; }
"until"     { return UNTIL; }
"read"      { return READ; }
"write"     { return WRITE; }
":="        { return AFF; }

"+"         { attribut.copadd = PLUS; return OPADD; }
"-"         { attribut.copadd = MOINS; return OPADD; }
"*"         { attribut.copmul = MULT; return OPMUL; }
"/"         { attribut.copmul = DIV; return OPMUL; }
"="         { attribut.coprel = EGAL; return OPREL; }
"<"         { attribut.coprel = INF; return OPREL; }

{chiffre}+  { attribut.valeur = atoi(yytext); return ENTIER; }
{ident}     { 
    attribut.nom = strdup(yytext);
    if (!attribut.nom) {
        fprintf(stderr, "Erreur : échec d'allocation mémoire pour IDENT\n");
        exit(-1);
    }
    return IDENT; 
}

[ \t\n]+    { /* Ignorer les espaces, tabulations et sauts de ligne */ }
.           { erreur_lexicale(yytext); }

%%

int main() {
    printf("Veuillez entrer le programme source \n");
    enum TOKEN tc;
    while ((tc = yylex()) != 0) {
        switch (tc) {
            case PV: printf("<PV, >\n"); break;
            case IF: printf("<IF, >\n"); break;
            case THEN: printf("<THEN, >\n"); break;
            case ELSE: printf("<ELSE, >\n"); break;
            case END: printf("<END, >\n"); break;
            case REPEAT: printf("<REPEAT, >\n"); break;
            case UNTIL: printf("<UNTIL, >\n"); break;
            case READ: printf("<READ, >\n"); break;
            case WRITE: printf("<WRITE, >\n"); break;
            case AFF: printf("<AFF, >\n"); break;

            case OPADD:
                printf("<OPADD, %s>\n", (attribut.copadd == PLUS) ? "PLUS" : "MOINS");
                break;
            case OPMUL:
                printf("<OPMUL, %s>\n", (attribut.copmul == MULT) ? "MULT" : "DIV");
                break;
            case OPREL:
                printf("<OPREL, %s>\n", (attribut.coprel == EGAL) ? "EGAL" : "INF");
                break;
            case PARG: printf("<PARG, >\n"); break;
            case PARD: printf("<PARD, >\n"); break;
            case IDENT: printf("<IDENT, %s>\n", attribut.nom); break;
            case ENTIER: printf("<ENTIER, %d>\n", attribut.valeur); break;
            default:
                printf("Token inconnu : %d\n", tc);
                break;
        }
    }
    printf("<FIN, >\n");
    return 0;
}

int yywrap() {
    return 1;
}
