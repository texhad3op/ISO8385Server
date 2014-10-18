-module(client).
-compile(export_all).
-import(lists, [reverse/1]).
-include("field_constants.hrl").
-import(iso_message, [generate_message/2]).

start() ->
    start("127.0.0.1", 8080).	
	
start(Host, Port) ->

    {ok,Socket} = gen_tcp:connect(Host,Port,[binary, {packet, 0}]), 
    ok = gen_tcp:send(Socket, get_message()),
	
	Answer = receive_data(Socket, []),
	Message = iso_message:get_message_values(Answer),
	iso_message:print_message(Message),
	gen_tcp:close(Socket).	

	
receive_data(Socket, SoFar)->
	socket_processing:process_data(Socket, SoFar).

get_message()->
	MessageValues = dict:from_list(
			[{?PRIMARY_ACCOUNT_NUMBER, "9826132500000000181"},
			{?PROCESSING_CODE, "000000"},
			{?AMOUNT_TRANSACTION, "000000001000"},
			{?TRANSMISSION_DATE_AND_TIME, "0914225918"},
			{?SYSTEM_TRACE_AUDIT_NUMBER, "000155"},
			{?TIME_LOCAL_TRANSACTION, "235918"},
			{?DATE_LOCAL_TRANSACTION, "0914"},
			{?DATE_EXPIRATION, "0201"},
			{?DATE_SETTLEMENT, "0914"},
			{?MERCHANTS_TYPE, "0000"},
			{?POINT_OF_SERVICE_ENTRY_MODE, "020"},
			{?POINT_OF_SERVICE_CONDITION_CODE, "00"},
			{?AMOUNT_TRANSACTION_FEE, "C00000000"},
			{?ACQUIRING_INSTITUTION_IDENT_CODE, "000002"},
			{?FORWARDING_INSTITUTION_IDENT_CODE, "000002"},
			{?TRACK_2_DATA, "9826132500000000181=02017650000000000"},
			{?RETRIEVAL_REFERENCE_NUMBER, "PCZ257000155"},
			{?CARD_ACCEPTOR_TERMINAL_IDENTIFICACION, "02117986"},
			{?CARD_ACCEPTOR_IDENTIFICATION_CODE, "000000000020553"},
			{?CARD_ACCEPTOR_NAME_LOCATION,
					"Location2              Welwyn Garden01GB"},
			{?CURRENCY_CODE_TRANSACTION, "826"},
			{?RESERVED_NATIONAL, "0000456445|0000|PCZ257000155"},
			{?RESERVED_PRIVATE_USE1, "20010120402C101"}]),
			
	Message = generate_message("0200", MessageValues),
	Message.