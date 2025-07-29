# Stupyder test file
A bunch of simple code snippets in different languages to test Stupyder.nvim

## Python Demos

### Basic hello world
```python
print("hello, world")
```

### Demo to show incremental output working
```python
import time

print("hello, world!\n")
for i in range(0, 3):
    time.sleep(1)
    print(i, flush=True)
```

### Bash script example
```bash
echo "ahhhh" >> somefile
cat somefile
```

### Lua example + theme change
```lua
print("hello")

vim.cmd("colorscheme blue")

```

reset colorscheme
```lua
vim.cmd("colorscheme tearout")
```

## Compiled Languages

### C hello world
```c
#include <stdio.h>

int main() {
    printf("hello!\n");
    return 0;
}
```


### Golang hello world
```go
package main

import ("fmt")

func main() {
    fmt.Println("Hey")
}
```

