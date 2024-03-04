## Programming Language:
- Prolog
## Problem Description:
# Project README

## Introduction

One beautiful day, you hear about a hacker attack on the IST-Tagus room occupancy database. In an attempt to help, you study the relevant data structures (Section 1), create a program in Prolog (first lines in Section 2), and solve the problem. You become a hero, but as you know, with great powers come great responsibilities, and more requests for help start pouring in (Section 3). Of course, you give your best! For project implementation conditions, evaluation, and recommendations, see Sections 4 and 5.

## Data Structures

There are two files - `dados.pl` and `keywords.pl` - which constitute part of a freely modified version of a knowledge base kindly provided by the Academic Area and Building Management. The file `dados.pl` contains facts about events, shifts associated with events, and event schedules, defined as follows:

An event, `evento(ID, NomeDisciplina, Tipologia, NumAlunos, Sala)`, is characterized by:
- An identifier;
- The name of the discipline associated with the event;
- The type of event (seminar, theoretical, etc.);
- The number of students associated with the event;
- The room where the event takes place.

An event is associated with one or more shifts, `turno(ID, SiglaCurso, Ano, NomeTurma)`, characterized by:
- An identifier (the ID of the associated event);
- The course acronym to which the event belongs;
- The year in which the discipline is offered in the course;
- The name of the shift.

An event also has an associated schedule, `horario(ID, DiaSemana, HoraInicio, HoraFim, Duracao, Periodo)`, characterized by:
- An identifier (the ID of the associated event);
- The day of the week when the event takes place;
- The start and end hours of the event;
- The duration of the event (yes, it could be deduced from the previous values);
- The period in which the event takes place.

For example, the following facts indicate that event 10 concerns a laboratory of the subject 'Digital Systems', with 18 students and takes place in room 1-62. It takes place on Fridays, between 8:00 am and 10:00 am, with a duration of two hours, and takes place in p2. This event is from the first year of the LEE, classes lee0101, and lee0102.

```
evento(10, 'sistemas digitais', laboratorial, 18, '1-62').
horario(10, sexta-feira, 8.0, 10.0, 2.0, p2).
turno(10, lee, 1, lee0102).
turno(10, lee, 1, lee0101).
```

The file "keywords.pl" contains keywords that will be useful. For example:

```
salas(grandesAnfiteatros, ['a1', 'a2']).
...
salas(videoConf, ['0-19', '0-13']).
...
licenciaturas(tagus, ['lee', 'legi', 'leic-t', 'leti']).
mestrados(tagus, ['mbmrp', 'mee', 'megi', 'meic-t', 'meti']).
```

## Prolog Program

The Prolog file (`.pl` extension) to be used in the project should have the following initial lines:

```
% Number and name of the student
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % for complete lists
:- ['dados.pl'], ['keywords.pl']. % files to import.
/*
Code
*/
```

## Implemented Predicates

### Quality of Data

The first request for help comes from the Secretary: they ask you to help them find problematic events; especially, they ask you to identify/find:
- Events without rooms;
- Events without rooms, given a day of the week;
- Events without rooms, given a period.

You roll up your sleeves and embrace the challenge with enthusiasm.

### Simple Searches

You receive a big thank you from the Secretary for your excellent work and prepare to return to God of War/watch the latest episode of Arcane/Re-watch Attack on Titan/Other (scratch what doesn't matter), when the Academic Area contacts you: they need help implementing a set of predicates. Once again, without a sigh, you roll up your sleeves and get back to work.

You start by implementing - without using higher-order predicates, meaning the predicates you define must use recursion (whether they generate recursive processes or iterative ones) - the predicate `organizaEventos/3`, such that:
- `organizaEventos(ListaEventos, Periodo, EventosNoPeriodo)` is true if `EventosNoPeriodo` is the list, ordered and without repeated elements, of IDs of events from `ListaEventos` that occur in the period `Periodo` for pi, i ∈ {1,2,3,4}.

You also implement the predicate `eventosMenoresQue/2`, such that:
- `eventosMenoresQue(Duracao, ListaEventosMenoresQue)` is true if `ListaEventosMenoresQue` is the ordered list without repeated elements of identifiers of events that have a duration less than or equal to `Duracao`.

You further implement the predicate `eventosMenoresQueBool/2`, such that:
- `eventosMenoresQueBool(ID, Duracao)` is true if the event identified by `ID` has a duration equal to or less than `Duracao`.

You also implement

 the predicate `salasNecessarias/3`, such that:
- `salasNecessarias(ID, Dia, ListaSalas)` is true if `ListaSalas` is the ordered list without repeated elements of the rooms where the event identified by `ID` takes place on the day `Dia`.

Finally, you implement the predicate `sobrelotacao/3`, such that:
- `sobrelotacao(ListaEventos, Sala, Acumulador)` is true if `Acumulador` is the number of students in the events in `ListaEventos` that take place in room `Sala`.

### Advanced Searches

Once again, your excellent work is recognized, and you receive another request for help. This time, it comes from the Building Management: they want to know the rooms that will be occupied at each time of day. You prepare to dive into the task at hand.

You start by implementing the predicate `salaOcupada/3`, such that:
- `salaOcupada(Dia, Hora, SalasOcupadas)` is true if `SalasOcupadas` is the ordered list without repeated elements of the rooms that are occupied on the day `Dia` at the hour `Hora`.

You also implement the predicate `eventosOcorremNaSala/3`, such that:
- `eventosOcorremNaSala(IDs, Sala, EventosOcorrem)` is true if `EventosOcorrem` is the list of identifiers of events in `IDs` that take place in room `Sala`.

Finally, you implement the predicate `eventosNoPeriodo/3`, such that:
- `eventosNoPeriodo(Periodo, Dia, EventosOcorrem)` is true if `EventosOcorrem` is the list of identifiers of events that take place on day `Dia` in the period `Periodo`.

## Implementation Conditions

The implementation conditions for the Prolog code are as follows:
- Do not use assert or retract.
- The code must be based on recursion.
- All predicates must terminate.

## Evaluation

The evaluation will be based on the following criteria:
- Completeness and correctness of the implementation;
- Efficiency and elegance of the implemented predicates;
- Quality and clarity of the comments;
- Readability and organization of the code.

## Recommendations

Remember to organize your code well, use explanatory variable names, and comment on the main points of your code. Think about edge cases and test your code thoroughly. Finally, keep in mind the conditions for implementation and evaluate whether your solution meets them.

## Conclusion

Your work here is done for now. Congratulations on your success in solving these challenging problems in Prolog! May your future endeavors be as fruitful and satisfying as this one. Until next time, happy coding!