%----------------------------------------
%               MODULES
%----------------------------------------
:- use_module('course.pl').


%----------------------------------------
%              UTILITIES
%----------------------------------------
if(Test, Then, Else) :-
    Test, !, Then 
    ;
    Else.

if(Test, Then) :- if(Test, Then, true).

isSpace(Ch) :- code_type(Ch,space).
isNotSpace(Ch) :- not(isSpace(Ch)).

removeSpace([],[]).
removeSpace([ X | XS ], Rest) :-
	if( isSpace(X),
	    removeSpace(XS, Rest),
	    Rest=[ X | XS ]
	  ).
%-----------------------------------------

sched(CourseFile, RoomFile, NumSlots) :-
    catch( read_file_to_codes(CourseFile,Codes,[]),
			_,
			( writef('\nCouldn\'t open %d.\n',[CourseFile]),
			fail
			)
        ),
        catch( read_file_to_codes(RoomFile, RoomCodes, []),
            _,
            ( 
                writef('\nCouldn\'t open %d.\n',[RoomFile]),
                fail
            )
        ),
        process_rooms(RoomCodes, RoomData),
        process_codes(Codes, CourseData),
        maplist(newCourse, CourseData, Courses),
        make_adj(Courses,Courses,TheCourses),
        numlist(1, NumSlots, TimeSlots),
        schedule(TheCourses,TimeSlots),
        nl,write('Courses:'),tab(8),
        write('Time:'),nl,nl,
        writeSchedule(TheCourses), !
        ;
        nl,write('Sorry, invalid data found. Please verify data given.').

process_rooms([],[]).
process_rooms(Codes, RoomData) :-
    removeSpace(Codes, Rest),
    get_name(Rest, NameCodes, Rest2),
    removeSpace(Rest2, Rest3),
    get_id(Rest3, CapacityCodes, Rest4),
    atom_codes(Name, NameCodes),
    number_codes(Capacity, CapacityCodes),
    removeSpace(Rest4, Remaining),
    process_rooms(Remaining, OtherRooms),
    not(member((Name,_), OtherRooms)),
    RoomData = [(Name,Capacity)|OtherRooms].

% Finds a valid instatiation of time slots for each course if possible
schedule([],[_|_]).
schedule([Course|Rest], [Slot|Slots]) :-
    schedule(Rest, [Slot|Slots]),
    Course = course(_,_,AdjList,Time),
    taken(AdjList,Taken),
    if(
        not(member(Slot, Taken)),
        ( % then
            Time = Slot
        ),
        ( % else
            schedule([Course], Slots)
        )
    ).

    

% Relates a list of (adjacent) courses with a list of the slots they’ve claimed
taken([],[]).
taken([Course|Rest], TakenSlots) :-
    taken(Rest, OtherTimes),
    Course = course(_,_,_,Time),
    if(
        (
            number(Time),
            not(member(Time, OtherTimes))
        ),
        TakenSlots = [Time|OtherTimes],
        TakenSlots = OtherTimes
    ).


% Creates a list of course/4 structures with instatiated adjacency list.
make_adj([],_,[]).
make_adj([Current|Rest],Courses, TheCourses) :-
    withAdjacent(Current,Courses),
    make_adj(Rest,Courses,Others),
    TheCourses = [Current|Others].



% Create a list of (<CourseName>, [<IDs>]) from file codes
% Assumes Codes starts with course name
%
% Codes ------> the file codes
% CourseData -> a list of (courseName,[IDs])
process_codes([],[]).
process_codes(Codes, CourseData) :-
    removeSpace(Codes, Rest),
    get_name(Rest, NameCodes, Rest2),
    get_ids(Rest2, IDs, Remaining),
    atom_codes(Name, NameCodes),
    process_codes(Remaining, OtherCourses),
    not(member((Name,_), OtherCourses)),
    CourseData = [(Name,IDs)|OtherCourses].
    


% Reads ID numbers from codes until another course is encountered, or until end of file.
%
% Codes -----> the file codes
% IDs -------> a list of ID numbers
% Remaining -> codes left after ID numbers are taken.
get_ids(Codes,IDs, Remaining) :-
    removeSpace(Codes, Rest),
    if( % End of file or course name
        (Rest = []; Rest = [First|_], not(code_type(First,digit))),
        (!, IDs = [], Remaining = Rest),
        (
            get_id(Rest,ID,Rest2),
            number_codes(Number, ID),
            Number // 1000000 =:= 201,
            get_ids(Rest2, OtherIDs, Remaining),
            not(member(Number, OtherIDs)),
            IDs = [Number|OtherIDs]
        )
    ).

% Reads a single ID number
%
% Codes -----> the file codes
% ID --------> codes for a single ID number
% Remaining -> codes left after ID number is taken.
get_id([],[],[]).
get_id(Codes, ID, Remaining) :-
    Codes = [First|Rest],
    if(
        isSpace(First),
        (!, ID = [], Remaining = Codes),
        (
            get_id(Rest, OtherID, Remaining),
            code_type(First,digit),
            ID = [First|OtherID]
        )
    ).
    
    
% Reads a course name as codes until white space
%
% Codes -----> the file codes
% Name-------> codes for a course name
% Remaining -> codes left after name is taken.  
get_name(Codes, Name, Remaining) :-
    Codes = [First|Rest],
    if(isSpace(First),
        (!, Name = [], Remaining = Codes),
        (   
            get_name(Rest, OtherName, Remaining),
            code_type(First,csym),
            Name = [First|OtherName]
        )
    ).


% Given a list of course/4 structures, this prints the name of each
% to the output along with the slot into which it has been scheduled. 
writeSchedule([]) :- nl.
writeSchedule([Course|Rest]) :-
    Course = course(Name,_,_,Time),
    write(Name),
    tab(8),
    write(Time),
    nl,
    writeSchedule(Rest).