-module(iso8385server).
-compile(export_all).
-import(lists, [reverse/1]).
-include("field_constants.hrl").
-import(iso_message, [get_message_values/1, get_answer_code_for_message/1, get_message_structure/1]).

start()->
    {ok, Listen} = gen_tcp:listen(8080, [binary, {packet, 0},
					 {reuseaddr, true},
					 {active, true}]),
	io:format("Listen...~n"),
    process(Listen).	

process(Listen)->
	{ok, Socket} = gen_tcp:accept(Listen),
	socket_processor(Socket),
    process(Listen).	

socket_processor(Socket)->
	io:format("Accepted...~n"),	
	Answer = receive_data(Socket, []),
	Message = iso_message:get_message_values(Answer),
	process_message(Socket, Message).
	

receive_data(Socket, SoFar)->
	socket_processing:process_data(Socket, SoFar).
	
process_message(Socket, {MTI, MessageIn})->

	RespMTI = iso_message:get_answer_code_for_message(MTI),
	
	iso_message:print_message({MTI, MessageIn}),
	Pan = case dict:fetch(?PRIMARY_ACCOUNT_NUMBER, MessageIn) of
		[Val]->Val;
		error->" "
	end,

	RRN = case dict:fetch(?RETRIEVAL_REFERENCE_NUMBER, MessageIn) of
		[Val1]->Val1;
		error->" "
	end,	

	io:format("!!!!!!!!!!!!>~p<",[RRN]),	
	
	MessageValues = dict:from_list(
		[
		{?PRIMARY_ACCOUNT_NUMBER, Pan},
		{?RESPONSE_CODE, "20"},
		{?RETRIEVAL_REFERENCE_NUMBER, RRN},
		{?ADDITIONAL_RESPONSE_DATA, "1234567890123456789012345"}
		]),
		
		
	ResponseMessage = iso_message:generate_message(RespMTI, MessageValues),	
	MMM = iso_message:get_message_values(ResponseMessage),
	io:format("???????~n"),	
	iso_message:print_message(MMM),
	io:format("???????~n"),	
	gen_tcp:send(Socket, ResponseMessage).