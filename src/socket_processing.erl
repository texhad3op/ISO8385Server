-module(socket_processing).
-export([process_data/2]).

process_data(Socket, SoFar) ->
    receive
		{tcp, Socket, Bin} -> 
			io:format("<<<<~p~n",[Bin]),
			WholeMessageLength = length(binary_to_list(Bin)),
			Ret = 
			if 
				2 < WholeMessageLength -> 
					<<Length1:8, Length2:8, _/binary >> = Bin,
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
			io:format("!!!Socket was closed!!!"),
			list_to_binary(lists:reverse(SoFar))
        after 1000->
                io:format("Send timeout, closing!~n",
						  []),
			gen_tcp:close(Socket)		
    end.
	
extract_length(A, B)->
	case A of 
		0 -> B;
		_ -> A+255+B
	end.