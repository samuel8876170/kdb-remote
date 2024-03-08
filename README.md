# kdb-remote

Library to remote control q/kdb+ processes
</br></br>

## Table of Contents

- [kdb-remote](#kdb-remote)
  - [Table of Contents](#table-of-contents)
    - [Features](#features)
    - [Installation](#installation)
    - [Execution](#execution)

</br>

### Features

1. Execute code on background q processes (or any q processes which terminals are not reachable)
    - i.e. It is not possible to open up its terminal and run the code directly
2. Execute same code to multiple q processes
    - No need to open the terminal for each process and run the code one by one
3. Catch error message in remote q processes and show in result

### Installation

-   Download this repository:

```
git clone https://github.com/samuel8876170/kdb-remote.git
```

### Execution

1. Load this module

```q
q) \l remote.q
```

2. Execute code on local process

```q
q) .R.focus: `self
q) R) 0N!"hello world"
```

3. Execute code on single remote process

```q
q) .remote.add[`foo; "localhost:8090"; "username"; "password"]
q) .R.focus: `foo
q) R) 0N!"hello world"
```

4. Execute code on multiple remote processes

```q
q) .remote.del `foo
q) .remote.add[`foo1; "localhost:8091"; "username"; "password"]
q) .remote.add[`foo2; "localhost:8092"; (::); (::)]
q) .remote.add[`foo3; "localhost:8093"; (::); (::)]

q) .R.focus: `foo1`foo2`foo3
q) R) 0N!"hello world"
```
