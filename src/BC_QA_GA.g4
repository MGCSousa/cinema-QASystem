/*
 * Linguagem: "Questions & Answers"
 * Processador: Gramática de Atributos que permite o processamento de questões e suas respetivas respostas.
 * 
 * Alunos:
 *      Eduardo Gil Rocha - A77048
 *      Manuel Sousa - A78869
 */

grammar BC_QA_GA;

@header {
    import java.util.Map;
    import java.util.HashMap;
    import java.util.List;
    import java.util.ArrayList;
}

@members {
    public class Triplo {
        String tipoQ;
        String acao;
        ArrayList<String> keywords;
        
        public Triplo() {
            this.tipoQ = "";
            this.acao = "";
            this.keywords = new ArrayList<String>();
        }
        
        public void setKeywords(ArrayList<String> keywords) {
            for (String s : keywords) {
                this.keywords.add(s);
            }
        }
    }
          
    // Estrutura de dados principal.
    Map<String, Triplo> triplos;
}

insts
@init {
    // Iniciar o mapeamento de triplos.
    triplos = new HashMap<String, Triplo>();
}
    	: base questoes
;


/* Processamento Base de Conhecimento */

base    : 'BASE_CONHECIMENTO' '{' triplos '}'
;

triplos : (triplo)+
;

triplo  : '(' t=tipoQ ',' a=acao ',' '[' o=objetos ']' ')' '=' '\"' r=resposta '\"' ';'
        {
            Triplo t = new Triplo();
            t.tipoQ = $t.text;
            t.acao = $a.text;
            t.setKeywords($o.keywords);
            
            triplos.put($r.resp, t);
        }
;

tipoQ    : TIPO_Q
;

acao     : ACAO
;

objetos returns[ArrayList<String> keywords]
         : t1=TEXTO { $objetos.keywords = new ArrayList<>(); $objetos.keywords.add($t1.text); } 
           (',' t2=TEXTO { $objetos.keywords.add($t2.text); } )*
;

resposta returns[String resp]
          : n=NUMERO { $resposta.resp = $n.text;}
          | t1=TEXTO { $resposta.resp = $t1.text; } 
           (t2=TEXTO { $resposta.resp += (" " + $t2.text); } )*
;


/* Processamento Questões */    

questoes 
@init {
    System.out.println("\n########### Respostas às questões processadas: ###########");
}
         : 'QUESTOES' '{' 
                ( s=string 
                  { 
                      System.out.print("\n" + $s.pergunta.toString());      
                      System.out.println("?\nR: " + $s.resp + 
                                         " :: Keywords: " + $s.maxKeyFound + "/" 
                                                          + $s.maxKeywords);
                  } 
                )+ 
           '}'
;

string returns[int maxKeywords, int maxKeyFound, StringBuilder pergunta, String resp]
         : '\"' q=questao '?' '\"' ';'
         {
            $string.maxKeywords = 0;
            $string.maxKeyFound = 0;
            $string.pergunta = $q.pergunta;
            $string.resp = "ERRO! Não foi encontrada resposta.";
          
            String tipoQ = $q.tipo_Q;
            String acao = $q.verbo;
            ArrayList<String> keywords = $q.keywords;
            
            int maxTmp = 0;
            
            for (String r : triplos.keySet()) {
                Triplo t = triplos.get(r);
                
                if ( tipoQ.equals(t.tipoQ) && acao.equals(t.acao) ) {
                    $string.maxKeywords = t.keywords.size();
                    $string.resp = r; // Guarda resposta atual na variável auxiliar.
                    for (String k : keywords) {
                        if (t.keywords.contains(k)) {
                            maxTmp++;
                        }
                    }
                }
                
                if (maxTmp == t.keywords.size()) {
                    $string.maxKeyFound = maxTmp;
                    break; // Foi encontrada a resposta!
                } else if (maxTmp > $string.maxKeyFound) {
                    $string.maxKeyFound = maxTmp;
                }
                
                maxTmp = 0;
            }
         }
;

questao returns[String tipo_Q, String verbo, ArrayList<String> keywords, StringBuilder pergunta]
@init {
    $questao.keywords = new ArrayList<String>();
    $questao.pergunta = new StringBuilder();
}
         : ( t=TIPO_Q  
             { $questao.tipo_Q = $t.text; $questao.pergunta.append($t.text + " "); }
           | a=ACAO    
             { $questao.verbo = $a.text; $questao.pergunta.append($a.text + " "); }
           | c=(DETERMINANTE | PREPOSICAO)
             { $questao.pergunta.append($c.text + " "); }
           | k=TEXTO 
             { $questao.keywords.add($k.text); $questao.pergunta.append($k.text + " "); } )+
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
