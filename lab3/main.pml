mtype:states = {
    ERROR,
    INITIAL,
    AFTER_GREETING,
    AFTER_EHLO,
    AFTER_MAIL_FROM,
    AFTER_RCPT_TO,
    AFTER_DATA,
    AFTER_DATA_CHUNKS,
    AFTER_END_OF_DATA,
    AFTER_QUIT
};

mtype:states client_state = ERROR;

mtype:states server_state = ERROR;

mtype:msg_from_client_type = {
    CONNECTION_REQUEST,
    EHLO,
    MAIL_FROM,
    RCPT_TO,
    DATA,
    DATA_CHUNK,
    END_OF_DATA,
    QUIT
};


chan from_client = [1] of {mtype:msg_from_client_type};

mtype:msg_from_server_type = {
    GREETING,
    OK,
    CMD_SEQUENCE_ERROR,
    ANOTHER_ERROR,
};

chan from_server = [1] of {mtype:msg_from_server_type};

proctype Client()
{
    mtype:msg_from_server_type msg_from_server_t;

c_establish_connection:
    client_state = INITIAL;
    printf("\nClient state: %e\n", client_state);

    from_client!CONNECTION_REQUEST;

    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == GREETING ->
            client_state = AFTER_GREETING;
            printf("\nClient state: %e\n", client_state);
        :: else -> goto c_establish_connection;
    fi

c_send_ehlo:
    from_client!EHLO;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            client_state = AFTER_EHLO;
            printf("\nClient state: %e\n", client_state);
        :: else -> goto c_send_ehlo;
    fi

c_send_mail_from:
    from_client!MAIL_FROM;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            client_state = AFTER_MAIL_FROM;
            printf("\nClient state: %e\n", client_state);
        :: else -> goto c_send_mail_from;
    fi

    int rcpt_to_count = 3; // multiple recievers example
    int sent_rcpt_to = 0;
c_send_rcpt_to:
    from_client!RCPT_TO;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            sent_rcpt_to++;
            printf("\nSent %d RCPT TO of %d\n", sent_rcpt_to, rcpt_to_count);
            if
                :: rcpt_to_count <= sent_rcpt_to ->
                    client_state = AFTER_RCPT_TO;
                    printf("\nClient state: %e\n", client_state);
                :: else -> goto c_send_rcpt_to;
            fi
        :: else ->
            goto c_send_rcpt_to;
    fi

c_send_data:
    from_client!DATA;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            client_state = AFTER_DATA;
            printf("\nclient state: %e\n", client_state);
        :: else -> goto c_send_data;
    fi

    int data_chunk_count = 3; // multiple data chunk example
    int sent_data_chunks = 0;
c_send_data_chunk:
    from_client!DATA_CHUNK;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            sent_data_chunks++;
            printf("\nSent %d data chunks of %d\n", sent_data_chunks, data_chunk_count);
            if
                :: data_chunk_count <= sent_data_chunks ->
                    client_state = AFTER_DATA_CHUNKS;
                    printf("\nClient state: %e\n", client_state);
                :: else -> goto c_send_data_chunk;
            fi
        :: else ->
            goto c_send_data_chunk;
    fi

c_send_end_of_data:
    from_client!END_OF_DATA;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            client_state = AFTER_END_OF_DATA;
            printf("\nclient state: %e\n", client_state);
        :: else -> goto c_send_end_of_data;
    fi

c_send_quit:
    from_client!QUIT;
    from_server?msg_from_server_t;
    if
        :: msg_from_server_t == OK ->
            client_state = AFTER_QUIT;
            printf("\nclient state: %e\n", client_state);
        :: else -> goto c_send_end_of_data;
    fi
}

proctype Server()
{
    mtype:msg_from_client_type msg_from_client_t;

s_await_connection:
    server_state = INITIAL;
    printf("\nServer state: %e\n", server_state);

    from_client?msg_from_client_t;
    if
        :: msg_from_client_t == CONNECTION_REQUEST ->
            from_server!GREETING;
            server_state = AFTER_GREETING;
            printf("\nServer state: %e\n", server_state);
        :: else ->
            goto s_await_connection;
    fi

s_process_ehlo:
    from_client?msg_from_client_t;
    if
        :: msg_from_client_t == EHLO ->
            from_server!OK;
            server_state = AFTER_EHLO;
            printf("\nServer state: %e\n", server_state);
        :: else ->
            from_server!CMD_SEQUENCE_ERROR;
            goto s_process_ehlo;
    fi

s_process_mail_from:
    from_client?msg_from_client_t;
    if
        :: msg_from_client_t == MAIL_FROM ->
            from_server!OK;
            server_state = AFTER_MAIL_FROM;
            printf("\nServer state: %e\n", server_state);
        :: else ->
            from_server!CMD_SEQUENCE_ERROR;
            goto s_process_mail_from;
    fi

    int rcpt_to_count = 0;
s_process_rcpt_to:
    from_client?msg_from_client_t;
    if
        :: msg_from_client_t == RCPT_TO ->
            rcpt_to_count++;
            from_server!OK;
            printf("\nRecieved %d RCPT TO\n", rcpt_to_count);
            goto s_process_rcpt_to;
        :: msg_from_client_t == DATA ->
            from_server!OK;
            server_state = AFTER_DATA;
            printf("\nServer state: %e\n", server_state);
        :: else ->
            from_server!CMD_SEQUENCE_ERROR;
            goto s_process_rcpt_to;
    fi

    int data_chunk_count = 0;
s_process_data_chunk:
    from_client?msg_from_client_t;
    if
        :: msg_from_client_t == DATA_CHUNK ->
            from_server!OK;
            printf("\nRecieved %d data chunks\n", data_chunk_count);
            goto s_process_data_chunk;
        :: msg_from_client_t == END_OF_DATA ->
            from_server!OK;
            server_state = AFTER_END_OF_DATA;
            printf("\nServer state: %e\n", server_state);
        :: else ->
            from_server!CMD_SEQUENCE_ERROR;
            goto s_process_data_chunk;
    fi

s_process_after_data_end:
    from_client?msg_from_client_t;
    if
        :: msg_from_client_t == MAIL_FROM ->
            from_server!OK;
            server_state = AFTER_MAIL_FROM;
            printf("\nServer state: %e\n", server_state);
            goto s_process_rcpt_to;
        :: msg_from_client_t == QUIT ->
            from_server!OK;
            server_state = AFTER_QUIT;
            printf("\nServer state: %e\n", server_state);
        :: else ->
            from_server!CMD_SEQUENCE_ERROR;
            goto s_process_after_data_end
    fi
}


init
{
    run Server();
    run Client();
}
