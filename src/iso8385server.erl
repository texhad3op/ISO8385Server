-module(iso8385server).
-compile(export_all).
-import(lists, [reverse/1]).
-include("field_constants.hrl").
-import(iso_message, [get_message_values/1, get_answer_code_for_message/1, get_message_structure/1]).

start()->
	MsgNum = 1,
    {ok, Listen} = gen_tcp:listen(8080, [binary, {packet, 0},
					 {reuseaddr, true},
					 {active, true}]),
	io:format("Listen...~n"),
    process(Listen, MsgNum).	

process(Listen, MsgNum)->
	{ok, Socket} = gen_tcp:accept(Listen),
	socket_processor(Socket, MsgNum),
    process(Listen, MsgNum+1).	

socket_processor(Socket, MsgNum)->
	io:format("Accepted...~n"),	
	Answer = receive_data(Socket, []),
	Message = iso_message:get_message_values(Answer),
	io:format("from client [~p]", [MsgNum]),
	iso_message:print_message(Message),
	gen_tcp:send(Socket, "answer from server\r\n").		

receive_data(Socket, SoFar)->
	socket_processing:process_data(Socket, SoFar).
	
process_message({MTI, MessageIn})->
	RespMTI = iso_message:get_answer_code_for_message(MTI),
	Structure = iso_message:get_message_structure(RespMTI).