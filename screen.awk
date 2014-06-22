#!/bin/awk -f
BEGIN {
    SCREEN = "screen";
    DETACH = "-d";
    REATTACHE = "-r";

    getList();
    if (count > 0) {
        getInput();
    }
}

function getInput(_exit, _n, _list) {
    _exit = 0;
    showList();
    printf("screen: ");
    while (! _exit && getline > 0) {
        _n = $1 + 0;

        if (1 <= _n && _n <= count) {
            system (screenCmd(session[_n]));
            _list = 1;
        }
        else if ($1 == SCREEN) {
            system($0);
            _list = 1;
        }
        else if ($1 == ".") {
            _exit = 1;
        }
        else if ($1 == ".d") {
            if (DETACH == "-d") {
                DETACH = "-D";
            }
            else {
                DETACH = "-d";
            }
            printf("< %s>\n", screenCmd(""));
        }
        else if ($1 == "?" || $1 == ".help" || tolower($1) == "help") {
            printf(" .     to quit\n");
            printf(" .d    to toggle detach mode\n");
            printf(" .help to display help\n");
            printf(" .ls   to list sessions\n");
            printf(" .r    to toggle reattache mode\n");
            printf(" Enter a screen command\n");
            printf(" Enter a session ID to resume a screen session\n");
        }
        else if ($1 == ".ls" || $1 == ".list") {
            _list = 1;
        }
        else if ($1 == ".r") {
            if (REATTACHE == "-r") {
                REATTACHE = "-R";
            }
            else if (REATTACHE == "-R") {
                REATTACHE = "-RR";
            }
            else {
                REATTACHE = "-r";
            }
            printf("< %s>\n", screenCmd(""));
        }

        if (! _exit) {
            if (_list) {
                getList();
                showList();
                _list = 0;
            }
            printf("screen: ");
        }
    }
    printf("\n");

    return 1;
}

function showList(_i) {
    printf("\n");
    printf("%2s %-30s %s\n", "ID", "Session", "Status");
    printf("%2s %-30s %s\n", dashes(2), dashes(30), dashes(10));
    for (_i = 1; _i <= count; _i++) {
        printf("%2d %-30s %s\n", _i, sort[_i], status[_i]);
    }
    return 1;
}

function getList(_cmd, _r, _session, _status) {
    _cmd = "screen -ls";
    _r = 0;

    count = 0;
    delete session;
    delete status;
    delete sort;

    while ( (_cmd |getline) > 0) {
        _r++;
        if (_r > 3) {
            count++;
            session[count] = _session[0];
            status[count] = _status[0];
            sort[count] = _session[0];
            sub(/^[^.]*./, "", sort[count]);
        }

        _session[0] = _session[1];
        _status[0] = _status[1];

        _session[1] = $1;
        _status[1] = $2;
    }
    close(_cmd);

    bubsort();

    return _i;
}

function screenCmd(s) {
    return (SCREEN " " DETACH " " REATTACHE " " s);
}

function dashes(n, _i, _retval) {
    _retval = "";

    for (_i = 0; _i < n; _i++) {
        _retval = (_retval "-");
    }

    return _retval;
}

function bubsort(_i, _j) {
    for (_i = 1; _i < count; _i++) {
        for (_j = _i + 1; _j <= count; _j++) {
            if (tolower(sort[_j]) < tolower(sort[_i])) {
                bubswap(_i, _j);
            }
        }
    }
}

function bubswap(i, j, _tmp) {
    _tmp = session[i];
    session[i] = session[j];
    session[j] = _tmp;

    _tmp = status[i];
    status[i] = status[j];
    status[j] = _tmp;

    _tmp = sort[i];
    sort[i] = sort[j];
    sort[j] = _tmp;
}
