-module(tests).
-export([f/0, testf/0]).

f()->
	testf().
	
testf()->
	io:format("tiu!").