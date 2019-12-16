/*
 * Linguagem: "Questions & Answers"
 * Processador: Gramática Independente de Contexto para reconhecimento de questões e suas respetivas respostas.
 * 
 * Alunos:
 *      Eduardo Gil Rocha - A77048
 *      Manuel Sousa - A78869
 */

grammar BC_QA_GIC;

insts : base questoes
;


/* Processamento Base de Conhecimento */

base : 'BASE_CONHECIMENTO' '{' triplos '}'
;

triplos : (triplo)+
;

triplo : '(' tipoQ ',' acao ',' '[' objetos ']' ')' '=' '\"' resposta '\"' ';'
;

tipoQ : TIPO_Q
;

acao : ACAO
;

objetos : TEXTO (',' TEXTO)*
;

resposta : NUMERO
         | TEXTO (TEXTO)*
;


/* Processamento Questões */    

questoes : 'QUESTOES' '{' (string)+ '}'
;

string : '\"' questao '?' '\"' ';'
;

questao : ( TIPO_Q | ACAO | (DETERMINANTE | PREPOSICAO) | TEXTO )+
;


/* ANALISADOR LÉXICO */

TIPO_Q        : 'Qual' | 'Quem' | 'Quando' | 'Onde' ; 
ACAO          : 'é' | 'foi' ;
DETERMINANTE  : 'o' | 'a' | 'os' | 'as' ;
PREPOSICAO    : 'de' | 'da' | 'do' | 'em' | 'para' | 'sem' ;

NUMERO   : [0-9]+ ; 
TEXTO    : (LETRA)+ ;

Separador: ('\r'? '\n' | ' ' | '\t')+  -> skip ;

// LETRA não é um terminal. Simplesmente foi definido para simplificar outras expressões regulares.
fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚâêîôûÂÊÎÔÛãõÃÕàèìòùÀÈÌÒÙçÇ_] ;
