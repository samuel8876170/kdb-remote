/
.remote.connInfo
    - id        |   symbol
    - address   |   symbol
    - timeout   |   int
    - handle    |   int
\
.remote.connInfo: ([id:`u#enlist`self] address:enlist`; timeout:enlist 0N; handle:enlist 0i);

.remote.summary: {neg[.z.w] (show; .remote.connInfo)};

/
.remote.add[id; address; username; password; timeout]
    - id        |   symbol
    - address   |   string
    - username  |   string
    - password  |   string
    - timeout   |   int
\
.remote.add: {[id; address; username; password; timeout]
    `.remote.connInfo upsert (
        id;
        `$raze (((2-sum":"=address)#":"),address; 
            $[null username; enlist":"; ((1-sum":"=username)#":"),username]; 
            $[null password; enlist":"; ((1-sum":"=password)#":"),password]
        );
        "j"$timeout;
        0Ni
    )};
.remote.del: {[id] 
    if[not null h:.remote.connInfo[id]`handle; hclose h]; 
    .remote.connInfo _: id
    };

.remote.cache.res: ();

.z.pc: { update handle:0Ni from `.remote.connInfo where handle=x };

.R.focus: `self;
.R.val: {
    // simply value query locally if focus is `self
    if[.R.focus~`self; :value x];
    // raise error if some focus are not registered
    if[not all exec .R.focus in id from .remote.connInfo;
        '"remote: some current focus processes (",(raze string .R.focus),") are not registered. Please check out .remote.summary[]"
    ];

    // hopen to those disconnected process
    isFocus: $[0<=type .R.focus;any;] exec .R.focus =\: id from .remote.connInfo;
    update handle:@[hopen; ;0Ni] @' flip(address; timeout) from `.remote.connInfo where isFocus, null handle;

    // send query to each of the focused processes
    idHandle: select id, handle from .remote.connInfo where isFocus;
    .remote.cache.res: ([id:idHandle`id] res:c#`; error:c#""; backtrace:(c:count idHandle)#"");

    result: update id:(exec id from idHandle where not null handle) from idHandle[`handle] @\: (.Q.trp; {`res`error`backtrace!(value x;enlist" ";enlist" ")}; x; {`res`error`backtrace!(`;x;.Q.sbt y)});
    :.remote.cache.res: .remote.cache.res lj `id xkey result
    };
.R.e: { .R.val x };

\
.remote.add[`u1; "localhost:9081"; ::; ::; 3000]
.remote.add[`u2; "localhost:9082"; ::; ::; 3000]
.remote.add[`u3; "localhost:9083"; ::; ::; 3000]

.R.focus: `u1`u2`u3
R) 1+1

.R.focus: `self`u1
R) 1+1