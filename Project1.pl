%%%%%%%%%%%%%%%%%%%%%%%%%% Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start:-
    nl,nl,nl,
    write('1-Beginner      (2*2)'),nl,
    write('2-Intermediate  (3*3)'),nl,
    write('3-Expert        (4*4)'),nl,nl,
    write('Choice :'),
    read(N),nl,nl,nl,
    write('1-Easy'),nl,
    write('2-Medium'),nl,
    write('3-Hard'),nl,nl,
    write('Choice :'),
    read(L),nl,
    play(N,L).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Play Game %%%%%%%%%%%%%%%%%%%%%%%%%%%%
play(1,L):-
    getD(L,D),
    run(5, D, 'AA', ['##','01','##','02','##',
                     '03','  ','04','  ','05',
                     '##','06','##','07','##',
                     '08','  ','09','  ','10',
                     '##','11','##','12','##']).
play(2,L):-
    getD(L,D),
    run(7, D, 'AA', ['##','01','##','02','##','03','##',
                     '04','  ','05','  ','06','  ','07',
                     '##','08','##','09','##','10','##',
                     '11','  ','12','  ','13','  ','14',
                     '##','15','##','16','##','17','##',
                     '18','  ','19','  ','20','  ','21',
                     '##','22','##','23','##','24','##']).
play(3,L):-
    getD(L,D),
    run(9, D, 'AA', ['##','01','##','02','##','03','##','04','##',
                     '05','  ','06','  ','07','  ','08','  ','09',
                     '##','10','##','11','##','12','##','13','##',
                     '14','  ','15','  ','16','  ','17','  ','18',
                     '##','19','##','20','##','21','##','22','##',
                     '23','  ','24','  ','25','  ','26','  ','27',
                     '##','28','##','29','##','30','##','31','##',
                     '32','  ','33','  ','34','  ','35','  ','36',
                     '##','37','##','38','##','39','##','40','##']).

%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Depth %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getD(1,1).
getD(2,2).
getD(3,3).

%%%%%%%%%%%%%%%%%%% player turn VS Computer turn %%%%%%%%%%%%%%%%%%%
run(N, _, _, L):-
    isTerminal(L,Win, AS, BS),
    printState(N, 0, L), nl,
    write('Score for A :'),
    write(AS),nl,
    write('Score for B :'),
    write(BS),nl,nl,
    write('Winner is :'),
    write(Win),nl,!.

run(N, D, 'AA', L):-
    nl,write('Player Turn'),nl,
    printState(N, 0, L), nl,
    write('Enter Edge no : '),
    read(E),
    playerMove(N, E, L, NL),
    run(N, D, 'BB', NL).

run(N, D, 'BB', L):-
    nl,write('Computer Turn'),nl,
    printState(N, 0, L), nl,
    compTurn(N, D, L, NL),
    run(N, D, 'AA', NL).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Terminal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isTerminal(L, Win, AS, BS):-
    \+ member('  ', L),
    calScore(L, AS, BS),
    getWin(Win, AS, BS).

%%%%%%%%%%%%%%%%%%%%%%%% Calculate Score %%%%%%%%%%%%%%%%%%%%%%%%%%%
calScore([], 0, 0):-!.

calScore([H|T], NAS, BS):-
    H == 'AA',
    calScore(T, AS, BS),
    NAS is AS+1,!.

calScore([H|T], AS, NBS):-
    H == 'BB',
    calScore(T, AS, BS),
    NBS is BS+1,!.

calScore([_|T], AS, BS):-
    calScore(T, AS, BS).

%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Win %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getWin('A', AS, BS):-
    AS > BS, !.

getWin('B', AS, BS):-
    BS > AS, !.

getWin('D', _, _).

%%%%%%%%%%%%%%%%%%%%%%%%%% print State %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
printState(_,_,[]):-!.

printState(N, C, [H|L]):-
    0 is C mod N, nl,
    write(H),write(' '),
    NC is C+1,
    printState(N,NC,L),!.

printState(N, C, [H|L]):-
    write(H),write(' '),
    NC is C+1,
    printState(N,NC,L).

%%%%%%%%%%%%%%%%%%%%%%%%% Player Turn %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
playerMove(N, E, L, NL):-
    P is E*2-1,
    move(N, P, L, 'AA', NL).

%%%%%%%%%%%%%%%%%%%%%%%%% Replace Cell %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
replace([_|T], 0, C, [C|T]) :- !.

replace([H|T], P, C, [H|R]):-
    NP is P-1,
    replace(T, NP, C, R).

%%%%%%%%%%%%%%%%%%%%%%% Mark Completed Cells %%%%%%%%%%%%%%%%%%%%%%%%%
markCompletedCells(N, _, C, L, L):-
    C >= N*N, !.

markCompletedCells(N, WC, C, L, FL):-
    nth0(C,L,V),
    V == '  ',

    C1 is C-N,
    C2 is C+N,
    C3 is C-1,
    C4 is C+1,

    nth0(C1,L,V1),
    nth0(C2,L,V2),
    nth0(C3,L,V3),
    nth0(C4,L,V4),

    V1 == '**',
    V2 == '**',
    V3 == '**',
    V4 == '**',

    replace(L, C, WC, NL),
    NC is C+2,
    markCompletedCells(N, WC, NC, NL, FL), !.

markCompletedCells(N, WC, C, L, NL):-
    NC is C+2,
    markCompletedCells(N, WC, NC, L, NL).

%%%%%%%%%%%%%%%%%%%%%%%% Computer Turn %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compTurn(N, D, L, NL):-
    getBestChild(N, D, L, 'BB', s(_,P)),
    move(N, P, L, 'BB', NL).

%%%%%%%%%%%%%%%%%%%%%%%%% Get Best Child %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getBestChild(_, D, L, _, s(S,_)):-
    (isTerminal(L,_,_,_);D==0),
    getHeuristic(L,S),!.

getBestChild(N, D, L, C, R):-
    ND is D-1,
    bagof(NChild, getChildern(N, ND, L, C, 1, NChild), Childern),
    getBest(Childern, C, R).

%%%%%%%%%%%%%%%%%%%%%%%%%% Get childern %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getChildern(N, _, _, _, I, _):-
    I >= N*N,!.

getChildern(N, D, L, C, I, s(S,I)):-
    nth0(I,L,V),
    \+ V=='**',
    move(N, I, L, C, NL),
    swap(C, NC),
    getBestChild(N, D, NL, NC, s(S,_)).

getChildern(N, D, L, C, I, Child):-
    NI is I+2,
    getChildern(N, D, L, C, NI, Child).

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Best %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getBest(L, C, R):-
    C == 'AA',
    minChild(L, R),!.

getBest(L, _, R):-
    maxChild(L, R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
move(N, P, L, C, FL):-
    replace(L, P, '**', NL),
    markCompletedCells(N, C, 0, NL, FL).

%%%%%%%%%%%%%%%%%%%%%%%%% Get Heuristic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getHeuristic(L, S):-
    calScore(L, AS, BS),
    S is BS-AS.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Swap %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swap('AA','BB').
swap('BB','AA').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Min %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minChild([_], s(0,_)):-!.

minChild([X,_], X):-!.

minChild([s(S1,_)|T],s(S2,P2)):-
    minChild(T, s(S2,P2)),
    S2<S1,!.

minChild([s(S1,P1)|_],s(S1,P1)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Max %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxChild([_], s(0,_)):-!.

maxChild([X,_], X):-!.

maxChild([s(S1,_)|T],s(S2,P2)):-
    maxChild(T, s(S2,P2)),
    S2>S1,!.

maxChild([s(S1,P1)|_],s(S1,P1)).


