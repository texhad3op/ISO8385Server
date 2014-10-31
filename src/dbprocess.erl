-module(dbprocess).


start()->
	spawn(dbprocess, log_messages, []).

log_messages()->
	receive
		{qqq}->
		