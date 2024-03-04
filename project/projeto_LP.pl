% ist1107052, Tomas Bernardino.
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % listas completas
:-['dados.pl'],['keywords.pl']. % importes
/*
Nota: Todos os predicados pedidos devolvem true se os argumentos de input
cumprirem as restricoes do enunciado, pelo que tal nao sera referido
nos comentarios dos predicados de modo a evitar repeticoes.
*/

%%%%%%%%%%%%%%%
%%%%  3.1  %%%%
%%%%%%%%%%%%%%%

/*
E devolvida uma lista de IDs usando o predicado de ordem superior
findall/3 para encontrar todos os IDs sem sala e coloca-los numa lista,
e sort/2 para ordenar e eliminar elementos dessa lista.
*/
eventosSemSalas(EventosSemSala):-
    findall(ID,evento(ID,_,_,_,semSala),EventosSemSala1),
    sort(EventosSemSala1,EventosSemSala).

/*
Encontra os IDs que correspondem ao dia da semana dado e que nao tem
sala utilizando o findall/3 e sort/2 como explicado no predicado anterior.
*/
eventosSemSalasDiaSemana(DiaDaSemana,EventosSemSala):-
    eventosSemSalas(EventosSemSala2),
    findall(ID,(horario(ID,DiaDaSemana,_,_,_,_),member(ID,EventosSemSala2)),
    EventosSemSala1),sort(EventosSemSala1,EventosSemSala).


/*
Predicado auxiliar que verifica se um determinado Periodo e valido, ou
seja pertence a [p1,p2,p3,p4].
*/
periodo(Periodo):-member(Periodo,[p1,p2,p3,p4]),!.

/*
Predicado auxiliar que transforma os Semestres nos periodos respetivos
e vice versa.
*/
semestre_periodo(Semestre,Periodo):-
    ((Semestre == p1_2,member(Periodo,[p1,p2]));
    (Periodo == p1;Periodo == p2),Semestre = p1_2);
    (Semestre == p3_4,member(Periodo,[p3,p4]));
    (Periodo == p3;Periodo == p4),Semestre = p3_4.

/*
eventosSemSalasPeriodo comeca por chamar eventosSemSalas para formar a
lista de eventos sem salas, a seguir verifica se a Lista de periodos e 
constituida por periodos validos usando subset/2, depois encontra todos os
eventos sem salas associados ao periodo e ao semestre que contem o periodo
e acaba por ordenar a lista criada.
*/
eventosSemSalasPeriodo([],[]):-!.
eventosSemSalasPeriodo(ListaPeriodos,Eventos):-
    eventosSemSalas(EventosSemSala),subset(ListaPeriodos,[p1,p2,p3,p4]),
    findall(ID,(member(ID,EventosSemSala),horario(ID,_,_,_,_,Periodo),
    (member(Periodo,ListaPeriodos);(semestre_periodo(Periodo,Periodo1),
    member(Periodo1,ListaPeriodos)))),Eventos1),sort(Eventos1,Eventos).




%%%%%%%%%%%%%%%
%%%%  3.2  %%%%
%%%%%%%%%%%%%%%

/*
Recursao que verifica, para cada ID da lista ListaEventos dada,se 
pertence ao periodo dado, se sim adiciona-o(append/3) ordenadamente e
sem repeticoes(sort/2) a lista EventosNoPeriodo.
*/
organizaEventos([],_,[]).
organizaEventos([PrimeiroID|IDs_restantes],Periodo,EventosNoPeriodo):-
    horario(PrimeiroID,_,_,_,_,P),
    ( P == Periodo; (semestre_periodo(P,Periodo1),Periodo1 == Periodo)),
    organizaEventos(IDs_restantes,Periodo,EventosNoPeriodo1),
    append([PrimeiroID],EventosNoPeriodo1,EventosNoPeriodo2),
    sort(EventosNoPeriodo2,EventosNoPeriodo),!.

% Se o periodo nao pertencer, ignorar e continuar para o proximo.
organizaEventos([PrimeiroID|IDs_restantes],Periodo,EventosNoPeriodo):-
    horario(PrimeiroID,_,_,_,_,P),P \== Periodo,
    organizaEventos(IDs_restantes,Periodo,EventosNoPeriodo).


/* 
Retorna uma lista ordenada e sem repeticoes dos eventos com duracao 
menor ou igual a dada.
*/
eventosMenoresQue(Duracao,ListaEventosMenoresQue):-
    findall(ID,(horario(ID,_,_,_,Duracao1,_),
    Duracao1=<Duracao),ListaEventosMenoresQue1),
    sort(ListaEventosMenoresQue1,ListaEventosMenoresQue).

% Returna True se o evento tiver duracao igual ou menor a Duracao.
eventosMenoresQueBool(ID,Duracao):-
    eventosMenoresQue(Duracao,Eventos),member(ID,Eventos),!.

/*
Encontra os nomes das disciplinas do curso ordenadas alfabeticamente
atraves da correspondencia do ID de cada aparencia do nome do curso no
predicado turno com cada aparencia do nome da disciplina no predicado 
evento. Ordena no final.
*/
procuraDisciplinas(Curso,ListaDisciplinas):-
    findall(NomeDisciplina,(turno(ID,Curso,_,_),
    evento(ID,NomeDisciplina,_,_,_)),ListaDisciplinas1),
    sort(ListaDisciplinas1,ListaDisciplinas).


/*
Predicado auxiliar ao predicado organiza disciplinas, que vai verificar
o semestre a que cada disciplina corresponde atraves da filtragem do ID 
pelos predicados evento,turno e horario, e adiciona-a a lista do semestre
respetivo atraves do predicado built-in merge/3 (junta duas listas numa).
*/
aux_organizaDisciplinas([],_,[],[]).
aux_organizaDisciplinas([PrimeiraDisc|DiscRestantes],Curso,Semestre1,Semestre2):-
    evento(ID,PrimeiraDisc,_,_,_),turno(ID,Curso,_,_),horario(ID,_,_,_,_,Periodo),
    (((Periodo == p1 ; Periodo == p2; Periodo == p1_2),!,
    aux_organizaDisciplinas(DiscRestantes,Curso,Semestre3,Semestre2),
    merge([PrimeiraDisc],Semestre3,Semestre1));
    ((Periodo == p3 ; Periodo == p4; Periodo == p3_4),!,
    aux_organizaDisciplinas(DiscRestantes,Curso,Semestre1,Semestre4),
    merge([PrimeiraDisc],Semestre4,Semestre2))).
/*
Forma uma lista de duas listas utilizando o predicado acima para formar
cada uma lista (Semestre1 e Semestre2, respetivamente).
*/
organizaDisciplinas([],_,[]).
organizaDisciplinas(Disciplinas,Curso,[Semestre1,Semestre2]):-
    aux_organizaDisciplinas(Disciplinas,Curso,Semestre1,Semestre2).


% Predicado auxiliar para somar os elementos de uma lista.
soma_elementosLista([],0).
soma_elementosLista([Cabeca|Cauda],Soma):-
    soma_elementosLista(Cauda,Soma1), Soma is Soma1 + Cabeca.

/*
Devolve o total de horas dos eventos de um curso,ano e periodo dados,
comecando por incluir as disciplinas semestrais e verificar a validade do
Periodo. Depois de encontrar todos os IDs possiveis para o curso e o ano 
dados e, encontra todas as duracoes de um periodo Periodo correspondentes
a esses IDs, acabando por somar os elementos da lista anteriormente obtida.
*/
horasCurso(Periodo, Curso, Ano, TotalHoras):-
    semestre_periodo(Semestre,Periodo),periodo(Periodo),
    findall(ID,turno(ID,Curso,Ano,_),IDs_repetidos),
    sort(IDs_repetidos,IDs),
    findall(Duracao,((horario(ID,_,_,_,Duracao,Periodo);
    (horario(ID,_,_,_,Duracao,Semestre))),
    member(ID,IDs)),TotalHoras1),
    soma_elementosLista(TotalHoras1,TotalHoras),!.
    





% Predicado auxiliar para transformar numeros nos respetivos periodos.
numeroPeriodo(Numero,Periodo):-
    (Numero==1,Periodo = p1);(Numero==2,Periodo = p2);
    (Numero==3,Periodo = p3);(Numero==4,Periodo = p4).

/*
Este predicado encontra todos os tuplos na forma(Ano, Periodo, NumHoras),
utilizando horasCurso para calcular NumHoras.
Sao usados betweens de modo a ficar ordenado por ano e periodo crescentes,
recorrendo ao predicado numeroPeriodo definido acima(no caso dos periodos).
*/
evolucaoHorasCurso(Curso,Evolucao):-
    findall(Evolucao1,(between(1,3,Ano),between(1,4,Numero),
    numeroPeriodo(Numero,Periodo),
    horasCurso(Periodo,Curso,Ano,NumHoras),
    merge((Ano,Periodo,NumHoras),[],Evolucao1)),Evolucao).

%%%%%%%%%%%%%%%
%%%%  3.3  %%%%
%%%%%%%%%%%%%%%

% Predicado auxiliar para definir o maior de dois numeros.
max(N1,N2,Max):- N1 =< N2, Max is N2.
max(N1,N2,Max):- N1 > N2, Max is N1.

% Predicado auxiliar para definir o menor de dois numeros.
min(N1,N2,Min):- N1 >= N2, Min is N2.
min(N1,N2,Min):- N1 < N2, Min is N1.

/*
Predicado que retorna a sobreposicao entre a duracao (hora final - inicial)
dada e a duracao  do evento,recorrendo aos predicados anteriormente feitos
(max e min).
*/
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas):-
    max(HoraInicioDada,HoraInicioEvento,HoraInicio),
    min(HoraFimDada,HoraFimEvento,HoraFim),
    Horas is HoraFim-HoraInicio,Horas > 0.0,!.

/*
numHorasOcupadas retorna o numero de horas ocupadas nas salas do tipo 
TipoSala, no intervalo de tempo definido entre HoraInicio e HoraFim, no dia
da semana DiaSemana, e num periodo valido(p1,p2,p3,p4).
Comeca por fazer uma lista das salas possiveis para depois encontrar a 
lista de horas(usando ocupaSlot) que ocupam o intervalo de tempo dado,
acabando por somar os elementos da lista de horas para dar a SomaHoras.
*/

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras):-
    salas(TipoSala,Salas),findall(Horas,(evento(ID,_,_,_,Sala),
    horario(ID,DiaSemana,HoraInicio1,HoraFim1,_,P),member(Sala,Salas),
    ocupaSlot(HoraInicio, HoraFim, HoraInicio1, HoraFim1, Horas),
    (P == Periodo; (semestre_periodo(P,Periodo1),Periodo1 == Periodo)),
    periodo(Periodo)),ListaDuracoes),
    soma_elementosLista(ListaDuracoes,SomaHoras).

/*
Comeca por encontrar todas as salas do tipo TipoSala e a quantidade
dessas salas, depois calcula maximo de horas possiveis de serem ocupadas
por essas salas no intervalo de tempo (HoraIncio - HoraFim).
*/

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max):-
    salas(TipoSala,Salas),length(Salas,NumeroSalas),
    Max is (HoraFim-HoraInicio)*NumeroSalas.

%predicado que calcula a percentagem entre SomaHoras e Max.
percentagem(SomaHoras, Max, Percentagem):-
    Percentagem is (SomaHoras/Max)*100.



/*
Usando todos os predicados ja definidos neste capitulo
(direta e indiretamente), cria uma lista com todos os tuplos do tipo 
'casosCriticos(DiaSemana, TipoSala,Percentagem)'.
Comeca por descobrir o tipo de sala, depois o numero de horas ocupadas e a 
ocupacao maxima(predicao numHorasOcupadas e ocupacaoMax) das salas desse
tipo no intervalo de tempo dado(HoraInicio - HoraFim), que irao servir para
calcular a percentagem.
Consecutivamente calcula a percentagem e guarda,no caso de estar acima do 
Threshold, arredondando a e adicionando-a ao tuplo juntamente com o dia da
semana retirado do ID da sala e o tipo de sala.
*/

ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados):-
    findall(CasosCriticos,(evento(ID,_,_,_,Sala),
    horario(ID,DiaSemana,_,_,_,Periodo),
    salas(TipoSala,Salas),member(Sala,Salas),
    numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras),
    ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
    percentagem(SomaHoras, Max, Percentagem),Percentagem>Threshold,
    ceiling(Percentagem,PercentagemCerta),
    merge(casosCriticos(DiaSemana,TipoSala,PercentagemCerta),[],CasosCriticos)),Resultados1),
    sort(Resultados1,Resultados).



%%%%%%%%%%%%%%%
%%%%  3.4  %%%%
%%%%%%%%%%%%%%%

%Predicado auxiliar que verifica se dois nomes estao lado a lado numa lista.
adjacente(Nome1,Nome2,Lista):-
(nextto(Nome1,Nome2,Lista);nextto(Nome2,Nome1,Lista)).

/*
Predicado auxiliar que transforma uma lista normal para uma lista do tipo
mesa(lista com 3 listas).
*/
formaMesa(Mesaflat,Mesa):-
Mesaflat = [X1,X2,X3,X4,X5,X6,X7,X8],
Mesa = [[X1,X2,X3],[X4,X5],[X6,X7,X8]].

% Adiciona o Nome dado a cabeceira 1 
cab1(Nome,[[_,_,_],[Nome,_],[_,_,_]]):-!.

% Adiciona o Nome dado a cabeceira 1
cab2(Nome,[[_,_,_],[_,Nome],[_,_,_]]):-!.

/*
Se o primeiro Nome dado estiver na cabeceira 1, senta o segundo nome no
lugar 6 , se estiver na cabeceira 2, senta-o no lugar 3, ou seja, o segundo
fica a direita do primeiro.
*/
honra(Nome1,Nome2,[Lado1_3,[Cab1,Cab2],Lado6_8]):-
    ((Cab1 = Nome1,nth1(1,Lado6_8,Nome2),Cab1 \== Cab2);
    (Cab2 = Nome1,nth1(3,Lado1_3,Nome2),Cab2\==Cab1)).

/*
Recorrendo ao predicado adjacente/3 definido anteriormente,que verifica 
se duas pessoas estao sentadas lado a lado num dos lados da mesa, devolve 
todas as formas como duas pessoas podem estar sentadas lado a lado, excluindo
as cabeceiras.
(Ou seja ou estao sao adjacentes no lado 1_3 ou no lado 6_8 para ficarem lado a lado).
*/
lado(Nome1, Nome2,[Lado1_3,_,Lado6_8]):-
    adjacente(Nome1,Nome2,Lado1_3);adjacente(Nome1,Nome2,Lado6_8).

/*
Predicado auxiliar que transforma uma lista de listas (do tipo Mesa) 
em apenas uma lista com todos os seus elementos ordenados da mesma forma.
*/ 
flaTTen([Lado1_3,Cabeceiras,Lado6_8],MesaFlat):-
    append(Lado1_3,Cabeceiras,ListaInc),
    append(ListaInc,Lado6_8,MesaFlat).

retiraEl([],_,[]):-!.
retiraEl([El1|Restantes],El,LstResultante):-
    El1 \== El, retiraEl(Restantes,El,LstResultante1),
    append([El1],LstResultante1,LstResultante),!.
retiraEl([_|Restantes],El,LstResultante):-  
    retiraEl(Restantes,El,LstResultante).

/*
Este predicado auxiliar comeca por transformar Mesa numa lista apenas, 
usando o predicado flaTTen/2 definido anteriormente.
Depois vai sentar as pessoas com recurso a nth1/3, sabendo que,se uma das
pessoas estiver na cabeceira nao existe restricao, caso contrario, verifica
se a diferenca dos indices for diferente do valor Diferente dado,atraves do
predicado abs/2, que devolve o valor absoluto de uma expressao. No final 
volta a formar a mesa antes destruida pelo flaTTen com formaMesa e verifica
se nao existem elementos repetidos.
*/

negacao_lado_ou_frente(Nome1,Nome2,Mesa,Diferente):- flaTTen(Mesa,MesaFlat),
    nth1(Indice1,MesaFlat,Nome1),nth1(Indice2,MesaFlat,Nome2),
    ((member(Indice1,[4,5]);member(Indice2,[4,5]));
    (\+member(Indice1,[4,5]),\+member(Indice2,[4,5]),
    abs((Indice1-Indice2),Diferenca),Diferenca\==Diferente)),
    formaMesa(MesaFlat,Mesa),verifica_elementos(Mesa).

/*
Recorre ao predicado negacao_lado_ou_frente com o valor 1 como Diferente,
o que faz com que a restricao do predicado seja se duas pessoas nao estao 
uma ao lado da outra.
*/
naoLado(Nome1,Nome2,Mesa):-
    negacao_lado_ou_frente(Nome1,Nome2,Mesa,1).

/*
Se a primeira pessoa ficar de um lado, a outra pessoa tem de ficar no
outro lado com o mesmo indice(posicao da mesa).
*/
frente(Nome1,Nome2,[Lado1_3,_,Lado6_8]):-
    between(1,3,Indice),
    ((nth1(Indice,Lado1_3,Nome1),nth1(Indice,Lado6_8,Nome2));
    (nth1(Indice,Lado6_8,Nome1),nth1(Indice,Lado1_3,Nome2))).


/*
Tal como o naoLado, recorre ao predicado negacao_lado_ou_frente, mas com
 o valor 5 como Diferente,o que faz com que a restricao do predicado seja
  se duas pessoas nao estao a frente uma da outra.
*/
naoFrente(Nome1,Nome2,Mesa):-    
    negacao_lado_ou_frente(Nome1,Nome2,Mesa,5).
  

/*
Este predicado vai servir de restricao para outros predicados, pois
verifica se o tamanho da Mesa reduzida a uma lista e igual se ela
estiver ordenada ou nao,ou seja, se nao existem elementos repetidos na 
Mesa que recebe como argumento.
*/
verifica_elementos(Mesa):-
    flaTTen(Mesa,Lista_Completa),length(Lista_Completa,N),
    sort(Lista_Completa,Lista_ord),length(Lista_ord,L),L =:= N.


% Predicado auxiliar para adicionar um elemento no final de uma lista.
inserir_ultimo([],El,[El]).
inserir_ultimo([Primeiro|Restantes],El,[Primeiro|Lista]):-
    inserir_ultimo(Restantes,El,Lista).

/*
Recursao auxiliar que serve para adicionar o argumento Mesa a cada
predicado presente em ListaRestricoes.
Primeiramente verifica se os predicados cab1 e cab2 existem na ListaRestrices,
no caso de existirem, irao ser as primeiras a ser modificadas.
Para modificar os predicados, comeca por usar os functores para transformar o
predicado em lista, onde ira ser adicionado o novo argumento Mesa.
Depois volta a transformar em functor e chama-o, verificando se nao existem
elementos iguais na mesa ate nao haverem mais predicados para chamar.
*/
ocupacao_Mesa_aux([],_):-!.

ocupacao_Mesa_aux(ListaRestricoes,Mesa):-
    (nth1(N,ListaRestricoes,cab1(_));nth1(N,ListaRestricoes,cab2(_))),
    nth1(N,ListaRestricoes,El), El=..Lista, 
    inserir_ultimo(Lista,Mesa,Lista1),El_novo=..Lista1,
    retiraEl(ListaRestricoes,El,Restantes),
    call(El_novo),!,ocupacao_Mesa_aux(Restantes,Mesa).

ocupacao_Mesa_aux([El1|Restantes],Mesa):-
    El1 =..Lista,inserir_ultimo(Lista,Mesa,Lista1), El1_novo=..Lista1,
    call(El1_novo),verifica_elementos(Mesa),
    ocupacao_Mesa_aux(Restantes,Mesa).

/*
Este predicado serve para substituir a variavel que houver na lista, no
caso de haver.Primeiramente encontra o Indice da variavel da lista
(primeiras duas linhas), depois faz duas listas, uma com todos os elementos
antes dessa variavel e outra com todos os elementos depois.
Consecutivamente, encontra a constante de Lista pessoas que nao esta na 
juncao das duas listas previamente criadas e acaba por juntar as duas listas
com essa Constante no meio. Com essa lista resultante, transforma a e devolve
a lista no tipo da lista mesa(lista com 3 listas).
*/

substitui_var(ListaPessoas,Mesa,OcupacaoMesa):-
    flaTTen(Mesa,Mesaflat),nth1(N,Mesaflat,X),member(X,Mesaflat),var(X),!,
    findall(Z1,(nth1(I,Mesaflat,Z1),I<N),Primeira_parte),
    findall(Z2,(nth1(I,Mesaflat,Z2),I>N),Segunda_parte),
    findall(Z3,(member(Z3,ListaPessoas),\+member(Z3,Primeira_parte),
    \+member(Z3,Segunda_parte)),Var),
    append(Primeira_parte,Var,L),append(L,Segunda_parte,Lista_Completa),
    formaMesa(Lista_Completa,OcupacaoMesa).

/*
O ultimo predicado comeca por criar uma mesa vazia, 
com dois lados de 3 pessoas e duas cabeceiras no meio.
Depois usa ocupacao_Mesa_aux para ir chamando cada predicado da ListaRestricoes.
Apos todas as restricoes, verifica se existem pessoas a que nao foram atribuidos
lugares, se sim, vai substituir a variavel que esta na mesa por essa pessoa,
se nao devolve a ocupacao da mesa completa(OcupacaoMesa).
*/
ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa):-
    Mesa = [[_,_,_],[_,_],[_,_,_]],
    ((ocupacao_Mesa_aux(ListaRestricoes,Mesa),
    substitui_var(ListaPessoas,Mesa,OcupacaoMesa));
    (ocupacao_Mesa_aux(ListaRestricoes,OcupacaoMesa),
    flaTTen(OcupacaoMesa,Mesaflat),sort(Mesaflat,[El1|_]),
    atomic(El1))).
