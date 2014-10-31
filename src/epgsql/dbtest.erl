-module(dbtest).
-include_lib("pgsql.hrl").
-export([dbquery/0, f/0]).

f()->0.
%lists:foreach(fun(E)-> io:format("~n~p",[E]), lists:seq(123456789, 123456799)).

dbquery() ->
		%lists:seq(123456789, 123456989)
%INSERT INTO opearations VALUES ('1234567890123456789', '0200', '000000', 98.5, 'testmessage');
	
	

    {ok,C} = pgsql:connect("localhost", "postgres", "password",[{database, "likontrotechcrm"},
									  {port, 5432}]),
    {ok, Cols, Rows} = pgsql:equery(C, "select * from events limit 10"),
	pgsql:close(C),
	io:format("something"),
	io:format("~p", [Rows]),
	Cols.