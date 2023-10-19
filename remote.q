/
.remote.connInfo_
    - id        |   symbol
    - address   |   symbol
    - timeout   |   int
    - handle    |   int
\
.remote.connInfo_: ([id:`u#``self] address:``; timeout:0N 0N; handle:0N 0i);

.remote.summary: {neg[.z.w] (show; 1_ .remote.connInfo_)};

/
.remote.add[id; address; username; password; timeout]
    - id        |   symbol
    - address   |   string
    - username  |   string
    - password  |   string
    - timeout   |   int
\
.remote.add: {[id; address; username; password; timeout]
    `.remote.connInfo_ upsert (
        id;
        `$raze (((2-sum":"=address)#":"),address; 
            $[null username; enlist":"; ((1-sum":"=username)#":"),username]; 
            $[null password; enlist":"; ((1-sum":"=password)#":"),password]
        );
        "j"$timeout;
        0Ni
    )};
.remote.del: {[id] 
    if[not null h:.remote.connInfo_[id]`handle; hclose h]; 
    .remote.connInfo_ _: id
    };

/
.remote.cache.res
    - id            |   `.remote.connInfo_ `id
    - res           |   any
    - error         |   string
    - backtrace     |   string
\
.remote.cache.res: ([id:`.remote.connInfo_$enlist`] res:enlist(::); error:enlist""; backtrace:enlist"");
.remote.cacheSummary: {1_ .remote.cache.res};

.z.pc: { update handle:0Ni from `.remote.connInfo_ where handle=x };

.R.focus: `self;

/
.R.query[ids; hs; query]
    - ids       |   list of symbol
    - hs        |   list of int
    - query     |   valuable
\
.R.query: {[ids; hs; query] update id:ids from hs @\: (.Q.trp; {`res`error`backtrace!(value x;enlist" ";enlist" ")}; query; {`res`error`backtrace!(`;x;.Q.sbt y)})};
.R.val: {
    // simply value query locally if focus is `self
    if[.R.focus~`self; :value x];
    // raise error if some focus are not registered
    if[not all exec .R.focus in id from .remote.connInfo_;
        '"remote: some current focus processes (",("," sv string .R.focus except exec id from .remote.connInfo_),") are not registered. Please check out .remote.summary[]."
    ];

    // hopen to those disconnected process
    isFocus: $[0<=type .R.focus;any;] exec .R.focus =\: id from .remote.connInfo_;
    update handle:@[hopen; ;0Ni] @' flip(address; timeout) from `.remote.connInfo_ where isFocus, null handle;

    // send query to each of the focused processes
    idHandle: select id, handle from .remote.connInfo_ where isFocus;
    @[`.remote.cache; `res; 1#];
    `.remote.cache.res insert (idHandle`id; c#" "; c#enlist"disconnected"; (c:count idHandle)#" ");
    
    idHandle @: where not null idHandle`handle;
    `.remote.cache.res upsert .R.query[idHandle`id; idHandle`handle; x];
    1_ .remote.cache.res
    };
.R.e: { .R.val x };

\
.remote.add[`u1; "localhost:40081"; ::; ::; 3000]
.remote.add[`u2; "localhost:40082"; ::; ::; 3000]
.remote.add[`u3; "localhost:40083"; ::; ::; 3000]

.R.focus: `u1`u2`u3
R) 1+1

.R.focus: `u1`self
R) 1+1

.R.focus: `self
R) 1+1