-module(socket_processing).
-export([process_data/2]).

process_data(Socket, SoFar) ->
    receive
		{tcp, Socket, Bin} -> 
			WholeMessageLength = length(binary_to_list(Bin)),
			Ret = 
			if 
				2 < WholeMessageLength -> 
					<<Length1:8, Length2:8, _/binary >> = Bin,
					io:format("~p ~p", [Length1, Length2]),
					RealMessageLength = extract_length(Length1, Length2),
					if 
						RealMessageLength+2 == WholeMessageLength -> 
								binary_to_list(Bin);
						true -> process_data(Socket, [Bin|SoFar])
					end;	
				true -> process_data(Socket, [Bin|SoFar])
			end,	
			Ret;
		{tcp_closed,Socket} -> 
			list_to_binary(lists:reverse(SoFar))
    end.
	
extract_length(A, B)->
	case A of 
		0 -> B;
		_ -> A+255+B
	end.