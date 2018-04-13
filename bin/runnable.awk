#!/bin/awk

# Pipe the output of jstack through this script to show only
# stack traces for PHT code in RUNNABLE threads

function push(line) {
    buf[bufSize++] = line
}

function flush() {
    for (i = 0; i < bufSize; i++) {
        print buf[i];
    }
    bufSize = 0;
}

BEGIN {
    false = 0; true = 1;

    show = false;
    discard = false;
    bufSize = 0;
}

/^".+"/ {
    if (show) {
        flush();
    }
    bufSize = 0;
    show = false;
    discard = false;
}

/^[ ]+java.lang.Thread.State:/ {
    runnable = null;
}

/^[ ]+java.lang.Thread.State: RUNNABLE/ {
    runnable = true;
}

/com.phtcorp|com.ert/ {
    if (runnable && !discard) {
        show = true;
    }
}

{
    if (show) {
        flush();
        print;
    } else if (!discard) {
        push($0);
    }
}

/com.googlecode.jsonrpc4j.JsonRpcServer.invoke/ {
   push("        ...");
   push("");
   flush();
   show = false;
   discard = true;
}

