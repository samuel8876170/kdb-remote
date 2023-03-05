//  .remote.connInfo
//  - id        |   symbol
//  - address   |   string
//  - username  |   string
//  - password  |   string
//  - handle    |   int
.remote.connInfo: ([id:`u#enlist`self] address:enlist""; username:enlist""; password:enlist""; handle:enlist 0i)
.remote.summary: {show .remote.connInfo;}
.remote.add: {[id; address; username; password]
    `.remote.connInfo upsert (
        id;
        ((2-sum":"=address)#":"),address;
        $[null username; enlist":"; ((1-sum":"=username)#":"),username];
        $[null password; enlist":"; ((1-sum":"=password)#":"),password];
        0Ni
    )
 }
.remote.del: {[id] 
    if[not null h:.remote.connInfo[id]`handle; hclose h]; 
    .remote.connInfo _: id
 }

.z.pc: {update handle:0Ni from `.remote.connInfo where handle=x}

.R.focus: `self
.R.val: {
    // simply value query locally if focus is `self
    if[.R.focus~`self; :value x];
    // raise error if some focus are not registered
    if[not all exec .R.focus in id from .remote.connInfo;
        '`$"remote: some current focus processes (",(raze string .R.focus),") are not registered. Please check out .remote.summary[]"
    ];

    // hopen to those disconnected process
    isFocus: exec any .R.focus =\: id from .remote.connInfo;
    update handle:@[hopen; ;{0Ni}]each(address ,' username ,' password) from `.remote.connInfo where isFocus, null handle;

    // select from .remote.connInfo where $[0<=type .R.focus; in; =][id; .R.focus]
    (exec handle from .remote.connInfo where isFocus, not null handle)@\:(value;x)
 }
.R.e: {.R.val x}