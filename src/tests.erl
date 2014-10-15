-module(tests).
-compile(export_all).

f()->
	io:format("~p", [d(1, 0)]).
	
d(A, B)->
	case A of 
		0 -> B;
		_ -> A+255+B
	end.