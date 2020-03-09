:- module(course,
    [
        newCourse/2,
        withAdjacent/2,
        writeCourse/1
    ] 
            ).


%----------------------------------------
%              UTILITIES
%----------------------------------------
if(Test, Then, Else) :-
    Test, !, Then 
    ;
    Else.

if(Test, Then) :- if(Test, Then, true).
%-----------------------------------------

%Produces a new course structure Course, given a course name and a list of unique student IDs.
newCourse((Name,IDs),Course) :- 
    Course = course(Name,IDs,_,_).

%Writes the given structure to the output in an easy-to-read way.
%This predicate is for testing purposes.
writeCourse(course(Name,IDs,_,_)) :-
    write('Name:    '),write(Name), nl,
    write('Students:'),write(IDs).

%Matches the adjacency set of Course against a subset of Courses. 
%In particular, against the set of all distinct courses whose student ID list overlaps with the list for Course. 
%Not that a course is never adjacent to itself.
%withAdjacent(Course,Courses) :-
withAdjacent(course(_,_,[],_),[]). % Initialize Adj list
withAdjacent(Course, [Other|Rest]) :-
    Course = course(Name1,IDs,Adj,_),
    Other = course(Name2,OtherIDs,_,_),
    withAdjacent(course(Name1,IDs,OldAdj,_),Rest),
    intersection(IDs, OtherIDs, Overlap),
    if( % Conflicting
        ( 
            not(Overlap = []),
            not(Name1 = Name2)
        ),
        (
            Adj = [Other|OldAdj], !
        ),
        Adj = OldAdj
    ).