## Stupyder test file
A bunch of simple code snippets in different languages to test Stupyder.nvim


## Python Demos

Basic hello world
```python
print("hello, world")
```

Demo to show incremental output working
```python
import time

print("hello, world!\n")
for i in range(0, 10):
    time.sleep(1)
    print(i, flush=True)
```

Bash script example
```bash
echo "ahhhh" >> somefile
cat somefile
```

Lua hello world
```lua
print("hello")

print(string.find("/tmp/XXXXXXXXXXXXXX", "[a-zA-Z]+12[a-zA-Z]+$"))

```

## Compiled Languages

C hello world
```c
#include <stdio.h>

int main() {
    printf("hello!\n");
    return 0;
}
```


Golang hello world
```go
package main

import ("fmt")

func main() {
    fmt.Println("Hey")
}
```

