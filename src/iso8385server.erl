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
	%io:format("from client [~p]", [MsgNum]),
	process_message(Socket, Message).
	

receive_data(Socket, SoFar)->
	socket_processing:process_data(Socket, SoFar).
	
process_message(Socket, {MTI, MessageIn})->

	RespMTI = iso_message:get_answer_code_for_message(MTI),
	%Structure = iso_message:get_message_structure(RespMTI),
	
	iso_message:print_message({MTI, MessageIn}),
	io:format("PRIMARY_ACCOUNT_NUMBER ~p", [dict:fetch(?PRIMARY_ACCOUNT_NUMBER, MessageIn)]),
		
	PAN = case dict:find(?PRIMARY_ACCOUNT_NUMBER, MessageIn) of
		{ok, Val}->Val;
		error->" "
	end,
	%io:format("PRIMARY_ACCOUNT_NUMBER ~p", [PAN]).

	RETRIEVAL_REFERENCE_NUMBER = case dict:find(?RETRIEVAL_REFERENCE_NUMBER, MessageIn) of
		{ok, Val1}->Val1;
		error->""
	end,	
	MessageValues = dict:from_list(
		[{?PRIMARY_ACCOUNT_NUMBER, PAN},
		{?RESPONSE_CODE, "20"},
		{?ADDITIONAL_RESPONSE_DATA, "1234567890123456789012345"},
		{?ADDITIONAL_AMOUNTS, "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"}
		%{?RESERVED_NATIONAL, "1234567890123456789012345"}		
		]),
		
		
	ResponseMessage = iso_message:generate_message(RespMTI, MessageValues),		
	MMM = iso_message:get_message_values(ResponseMessage),
	io:format("!!!!!!!!!!!!!"),
	iso_message:print_message(MMM),
	
	gen_tcp:send(Socket, ResponseMessage).