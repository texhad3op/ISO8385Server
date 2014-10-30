-module(iso8385server).
-export([start/0, process/1, process_message/2]).
-include("field_constants.hrl").


start()->
    {ok, Listen} = gen_tcp:listen(8080, [binary, {packet, 0},
					 {reuseaddr, true},
					 {active, true},
					 {send_timeout, 100},
					 {send_timeout_close, true}
					 ]),
	io:format("Listen...~n"),
    process(Listen).	

process(Listen)->
	{ok, Socket} = gen_tcp:accept(Listen),
	try 
		socket_processor(Socket)
	catch
		_: _ -> io:format("Was Error!!!")
	end,

    process(Listen).	

socket_processor(Socket)->
	io:format("Accepted...~n"),	
	Answer = receive_data(Socket, []),
	Message = iso_message:get_message_values(Answer),
	process_message(Socket, Message).
	

receive_data(Socket, SoFar)->
	socket_processing:process_data(Socket, SoFar).
	
	
get_message_value(Key, Dict)->
	case dict:fetch(Key, Dict) of
			[Val]->Val;
			error->""
	end.
	
process_message(Socket, {MTI, MessageIn})->
	ResponseMessage = case MTI of
		"0200"->process_message_0200(MessageIn);
		"0420"->process_message_0420(MessageIn)
	end,
	gen_tcp:send(Socket, ResponseMessage).
	
process_message_0200(MessageIn)->
	RespMTI = iso_message:get_answer_code_for_message("0200"),
	Pan = get_message_value(?PRIMARY_ACCOUNT_NUMBER, MessageIn),
	Rrn = get_message_value(?RETRIEVAL_REFERENCE_NUMBER, MessageIn),	
	MessageValues = dict:from_list(
		[
		{?PRIMARY_ACCOUNT_NUMBER, Pan},
		{?RESPONSE_CODE, "20"},
		{?RETRIEVAL_REFERENCE_NUMBER, Rrn},
		{?ADDITIONAL_RESPONSE_DATA, "1234567890123456789012345"}
		]),
	iso_message:generate_message(RespMTI, MessageValues).	
process_message_0420(_MessageIn)->
0.