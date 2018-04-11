Selene
======

<img src="logo/selene-logo-empty.png" width="300" />

This is a Lua library I made for more convenient functional programming. It provides special syntax as well as convenient functions on tables and strings.
### Table of contents
  - [Syntax](#syntax)
    - [Smart self-calling](#smart-self-calling)
    - [Assignment operators](#assignment-operators)
    - [Wrapped tables](#wrapped-tables)
      - [What you can do with wrapped tables or strings](#what-you-can-do-with-wrapped-tables-or-strings)
        - [Merging Wrapped Tables](#merging-wrapped-tables)
        - [Inserting values into lists](#inserting-values-into-lists)
        - [String iterators](#string-iterators)
      - [Utility functions for wrapped tables](#utility-functions-for-wrapped-tables)
    - [Iterables](#iterables)
    - [Lambdas](#lambdas)
      - [Conditional lambda functions](#conditional-lambda-functions)
      - [Composite functions](#composite-functions)
      - [Utility functions for wrapped and normal functions](#utility-functions-for-wrapped-and-normal-functions)
    - [Ternary Operators](#ternary-operators)
    - [Foreach](#foreach)
  - [Functions](#functions)
    - [bit32](#bit32)
    - [table](#table)
    - [string](#string)
    - [Wrapped tables](#wrapped-tables-1)
    - [Wrapped strings](#wrapped-strings)
  - [Running Selene](#running-selene)
  - [How Live Mode works](#how-live-mode-works)

# Syntax
This is a list of the special syntax available in Selene.
### Smart self-calling
A tweak that makes method calls with no parameters more convenient.
Basically, it allows doing this
```lua
local s = "Hello World"
local r = s:reverse
```
Which equates
```lua
local s = "Hello World"
local r = s:reverse()
```
### Assignment operators
Selene adds assignment operators for most operators in Lua.
```lua
a += 4   -- equates 'a = a + 4 '
a -= 4   -- equates 'a = a - 4 '
a *= 4   -- equates 'a = a * 4 '
a /= 4   -- equates 'a = a / 4 '
a //= 4  -- equates 'a = a // 4'
a %= 4   -- equates 'a = a % 4 '
a ^= 4   -- equates 'a = a ^ 4 '
a &= 4   -- equates 'a = a & 4 '
a |= 4   -- equates 'a = a | 4 '
a >>= 4  -- equates 'a = a >> 4'
a <<= 4  -- equates 'a = a << 4'
a ..= 4   -- equates 'a = a .. 4'

s = "Hello, World!"
s := split(",") -- equates 's = s:split(",")'
```
Having multiple operators in one term still works.
```lua
a *= 4 + 7  -- equates 'a = a * 4 + 7' (mind the order of operations)
a *= (4 + 7)  -- equates 'a = a * (4 + 7)' (use parentheses for this behaviour)
```
### Wrapped tables
You can use `$(t:table or string)` to turn a table or a string into a wrapped table or string to perform bulk data operations on them. If the table is a list (i.e. if every key in the table is a number valid for `ipairs`), it will automatically create a list, otherwise it will create a map.
```lua
local t = {"one", "two"}
t = $(t) -- Will create a list

local q = $("one", "two") -- You can also call this function with multiple arguments, it will create a list using each argument as a value

local p = {a="one", b="two"}
p = $(p) -- Will create a map

-- These are all the same.
local t1 = $({"one", "two"})
local t2 = $("one", "two")
local t3 = ${"one", "two"}

local s = "Fish"
s = $(s) -- Will create a wrapped string, you can iterate through each character just like you can using a list.

-- These are all the same.
local s1 = $("Fish")
local s2 = $"Fish"
local s3 = $'Fish'
local s4 = $[[Fish]]
local s5 = $[=[Fish]=]

-- You can use $o() to force wrapping strings or other tables.
local ws = $o(s) -- Will create a singleton list containing only s

local r = {"three", "four"}
r$$      -- equates 'r = $(r)'
```
If you want to enforce a certain type of wrapped table, you can use `$l()` to create a list and `$s()` to create a wrapped string. If the wrapped table of the specific type cannot be created for some reason, the function will error.

Turning a wrapped table or string back into a normal table or string is quite easy:
```lua
t = t() -- Calling the table like a function turns it back into a normal table
p = p:$ -- This also creates a table again
s = s.$ -- This is the third way of getting back your string or table.
s = tostring(s) -- This is a way of getting back strings from wrapped strings.
```
A note about wrapped strings: If you call `pairs` or `ipairs` with a wrapped string as a parameter, it will iterate through every character in the string.
#### What you can do with wrapped tables or strings
See [the functions documentation](#functions) for methods one may call on wrapped tables or strings.
##### Merging Wrapped Tables
You can merge maps, lists and stringlists by concatenating (`..`) them:
```lua
local t1 = {a = "one", c = 4, test = "three"}
local t2 = {test = "four", b = false, d = "fish"}
local t3 = $(t1)..$(t2) -- t3 is now {a="one", b=false, c=4, d="fish", test="four")}
```
The values of the second map will always overwrite keys of the first map in case both contain values assigned to the same keys.

If you concatenate lists, the values of the second one will be appended to those of the first one.
```lua
local t1 = {1, "two", true}
local t2 = {4, "five", 6}
local t3 = ($(t1) .. $(t2))() -- t3 is now {1, "two", true, 4, "five", 6}
```

You can merge any table with a map. Anything `isList` (see below) returns `true` on can be inserted into lists and stringlists can have stringlists inserted into them.
##### Inserting values into lists
You can insert any value into a list using the `+` operator:
```lua
local t1 = {1, "two", true}
local t2 = ($(t1) + 4)() -- t2 is now {1, "two", true, 4}
```
##### String Iterators
There are now three different ways to iterate through the characters of a string:
```lua
for index, char in ipairs($(s)) do
  -- Here, s is being turned into a wrapped string
end
for index, char in string.iter(s) do
  -- Here, string.iter is being used to give a string iterator
end
for index, char in $(s):iter do
  -- Here, the wrapped string's iterator function is being used.
end
```
#### Utility functions for wrapped tables
 - `ltype(t:anything):string` This functions works just like `type`, just that it, if it finds a wrapped table, may return `"map"`, `"list"` or `"stringlist"`.
 - `checkType(n:number, t:anything, types:string...)` This function errors when `t` does not match any of the specified types of wrapped tables. `n` is the index of the parameter, used for a more descriptive error message. if no type is specified, it will error if `t` is not a wrapped table.
 - `lpairs(t:wrapped table)` This functions works just like `ipairs` when called with a list or wrapped string and just like `pairs` when called with anything else.
 - `isList(t:wrapped table or table):boolean` This function returns true if the table is either a list (as a wrapped table) or a normal table that can be turned into a list (i.e. if every key in the table is a number valid for `ipairs`)

### Iterables
Iterables are objects that wrap a function to iterate over: The only parameter they take is a function that takes the current iteration index (or no parameter) and returns a value each time it is called, and nil when there is no new value left to return. Most of the [methods that can be called on wrapped tables](#wrapped-tables-1) can also be called on iterables.

```lua
local function supply(index)
  if index <= 10 then
    return index * index
  end
end

local itr = $(supply) -- Initializing an iterable for an existing function.

for i, j in pairs(itr) do -- This calls the function until it returns nil, starting with an iteration index of 1, and provides the iteration index and value.
  print(i, j)             -- In this case, the first ten squares of natural numbers are printed.
end

local itr2 = $(i -> i <= 10 and i*i or nil) -- Iterables can also be initialized using lambda functions.

for val in itr2 do -- This iterates through the iterable, only providing the value.
  print(val)
end

local itr3 = $( -> switch(math.random(0, 9),
  (val! val >= 3 -> val)
)) -- Of course, the supplier function does not have to use the index parameter.

for i, j <- itr3 do -- Selene's for loop syntax works as well.
  print(val)
end
```

### Lambdas
Lambdas are wrapped in `()` brackets and always look like `(<var1> [, var2, ...] -> <operation>)`. Alternatively to the `->` you can also use `=>`.
```lua
local t = {"one", "two"}
local g = $(t):filter((s -> s:find("t")))()
local h = $(t):filter(s => s:find("t"))() -- Alternative: If the lambda function is the only parameter of a function, you can omit one set of brackets.
-- g and h should both be {"two"} now
local f = (s, r -> s + r) -- f is now a function that, once executed with the parameters s and r, returns the sum of s and r.

local c = #f -- c is now 2; the length of a wrapped function is the number of parameters it accepts.
```
It will automatically be parsed into a wrapped Lua function, and, if the lambda does not contain any `return`, automatically add a `return` in the front.
#### Conditional lambda functions
Using the syntax `(<var1> [, var2, ...]! <condition> -> <operation>)`, you can specify a condition for the lambda function; the function will only be called if the condition is `true`.
```lua
local t = $(1, 2, nil, 6)
local g = t:map(i, s! type(s) == "number" -> i + s)()
-- g should be {2, 4, 10} now. Without the condition, it would error trying to calculate '3 + nil'.
```

#### Composite functions
Conditional functions can be added together to create a composite function. Calling this function will return the result of the first function `f` which `f.applies(...)` returns `true` for.

```lua
local f1 = (a! a < 4 -> 4)
local f2 = (a! a < 8 -> 8)
local f3 = (a! a < 10 -> 10)

local fc = f1 + f2 + f3

for i = 1,10 do
  print(fc(i) or "nothing")
end
```

#### Utility functions for wrapped and normal functions
 - `checkFunc(f:function, parCount:number...)` This function errors if the specified variable does not contain a function or a wrapped function. If it is a wrapped function, it will error if the amount of its parameters does not match any of the numbers given to this function.
 - `parCount(f:function, def:number or nil):number` This function errors if `f` is not a function or a wrapped function. If it is a normal function, it will return `def`. If it is a wrapped function, it will return the amount of its parameters. If it can't for some reason, it will return `def`.
 - `$f(f:function, parCount:number):wrapped function` This functions turns a normal Lua function into a wrapped function with the specified amount of parameters. This could be useful if you want to use `checkFunc` or `parCount` to depend on a specific number of parameters. You can call this wrapped function just like you can call any normal Lua function.

Furthermore, wrapped functions provide their own function `$f().applies(...)`
 ```lua
 local f = (s! type(s) == "number" -> s * 2)
 local c1 = f.applies(4) -- Should return 'true'
 local c2 = f.applies("hello") -- Should return 'false'
 
 -- On unconditional functions, 'applies' always returns 'true'
 local f2 = (s -> s .. "4")
 local c1 = f.applies(2) -- Should return 'true'
 ```

### Ternary Operators
Ternary operators are wrapped in `()` brackets and always look like `(<condition> ? <trueCase> : <falseCase>)`.
```lua
local a = 5
local c = (a >= 5 ? 1 : -1) -- c should be 1 now.
```
If `<condition>` is true, the first case will be returned, otherwise the second one will.
### Foreach
Selene supports alternative syntax for foreach:
```lua
local b = {"one", "two", "three"}
for i,j <- b do
  print(i, j)
end
```
If the table can be iterated through with `ipairs` (i.e. if every key in the table is a number valid for `ipairs`), it will choose that, otherwise it will choose `pairs`.

# Functions
This is a list of the functions available on wrapped tables or strings as specified [here](#syntax) as well as functions added to native libraries.

### global
 - `checkArg(n:number, obj:anything, types:string...)` This function errors when `obj` does not match any of the specified types. `n` is the index of the parameter, used for a more descriptive error message.
 - `switch(o:anything, funcs:function...)` This function returns the result of the first function `f` in `funcs` which `f.applies(o)` returns `true` for.
 If the function is not a [conditional function](#conditional-lambda-functions), it will always be called (`f.applies(o)` defaults to `true`).
```lua
local g = $(2, 4, 6, 10)
local r = switch(g,
  (n! #n > 5 -> "Hello"),
  (n! #n > 3 -> "World"),
  (n! #n > 1 -> "Banana")
)
-- r should be "World" now, because the second function is the first the condition of which holds true for with this instance of g. 
 ```

### bit32
Firstly, Selene adds two convenient functions to the `bit32` library (these functions are not available in Lua 5.3+), called fish-or or `for`:
 - `bit32.bfor(n1:number, n2:number, n3:number):number` This functions returns the bitwise fish-or of its operands. A bit will be 1 if two out of three of the operands' bits are 1.
 - `bit32.nfor(n1:anything, n2:anything, n3:anything):boolean` This returns `true` if two out of three of the operands are not `nil` and not `false`

### table
The native `table` library got two new functions:
 - `table.shallowcopy(t:table):table` This will return a copy `t` that contains every entry `t` did contain.
 - `table.flatten(t:table):table` This will collapse one level of inner tables and merge their entries into `t`. `t` needs to be a valid list (every key in the table has to be a number valid for `ipairs`). Inner tables will only get merged if they are lists as well, tables with invalid keys will stay the way they are in the table.
 - `table.range(start:number, stop:number [, step:number]):table` This will create a range of numbers ranging from `start` to `stop`, with a step size of `step` or 1.
 - `table.flip(t:table):table` Swaps every key in the table with its value and returns a new table.
 - `table.zipped(t1:table, t2:table):table` This will merge two tables into one if both have the same length, in the pattern `{{t1[1], t2[1]}, {t1[2], t2[2]}, ...}`
 - `table.clear(t:table):table` This will remove every value stored in `t` and return `t`.
 - `table.keys(t:table):table` Returns a new table containing all the keys stored in `t`. Will be in order if `t` can be iterated through using `ipairs`.
 - `table.values(t:table):table` Returns a new table containing all the values stored in `t`. Will be in order if `t` can be iterated through using `ipairs`.

### string
These functions will not work directly called on a string, i.e. `string.drop("Hello", 2)` will work but `("Hello"):drop(2)` will not. For that, use wrapped strings.
`function` may be a Lua function or a wrapped function (for instance a lambda).
 - `string.foreach(s:string, f:function)` This calls `f` once for every character in the string, with either the character or the index and the character as parameters.
 - `string.map(s:string, f:function):list or map` This function calls `f` once for every character in the string, with either the character or the index and the character as parameters, and inserts whatever it returns into a new table, which will then get returned as a list if possible and a map otherwise.
 - `string.flatmap(s:string, f:function):list` This works like `string.map(s, f):flatten`, meaning that it will apply a function that returns tables and afterwards try to flatten the results. See `string.map` and `$l():flatten`.
 - `string.filter(s:string, f:function):string` This function calls `f` once for every character in the string, with either the character or the index and the character as parameters, and, if `f` returns `true`, will insert the character into a new string which will get returned, meaning that every character `f` returns `false` on will be removed.
 - `string.contains(val:string):boolean` This returns true if the string contains the string `val`.
 - `string.count(f:function):number` This returns the amount of characters in the string that `f` returns `true` on.
 - `string.exists(f:function):boolean` This returns true if `f` returns `true` on any of the characters.
 - `string.forall(f:function):boolean` This returns true if `f` returns `true` on every character in the string.
 - `string.drop(s:string, n:number):string` This function will remove the first `n` characters from the string and return the new string.
 - `string.dropright(s:string, n:number):string` This function will remove the last `n` characters from the string and return the new string.
 - `string.dropwhile(s:string, f:function):string` This function will remove the first character of the string as long as `f` returns `true` on that character (or on the index and the character).
 - `string.take(s:string, n:number):string` This function will take the first `n` characters from the string and return the new string.
 - `string.takeright(s:string, n:number):string` This function will take the last `n` characters from the string and return the new string.
 - `string.takewhile(s:string, f:function):string` This function will iterate through the characters of the string and add the characters to the returned string as long as `f` returns `true` on the currently checked character (or on the index and the character).
 - `string.slice(s:string, start:number or nil, stop:number or nil [, step:number or nil]):stringlist` This function will slice a specific range of characters out of the string and return it, starting at index `start` and stopping at `stop` with a step size of `step`. `step` must not be 0 but can be negative. `start` will default to `1` if it is `nil` or `0`, `stop` will default to the length of the string. Negative values for `start` or `stop` are interpreted as indexing backwards, from the end of the string.
 - `string.fold(s:string, m:anything, f:function):anything` This works exactly like `string.foldleft`.
 - `string.foldleft(s:string, m:anything, f:function):anything` This function calls `f` once for every character in the string, with `m` and that character as parameters. The value which `f` returns will then be assigned to `m` for the next iteration. Returns the final value of `m`.
 - `string.foldright(s:string, m:anything, f:function):anything` This works exactly like `string.foldleft`, just that it starts iterating at the end of the string.
 - `string.reduce(s:string, f:function):anything` This works exactly like `string.reduceleft`.
 - `string.reduceleft(s:string, f:function):anything` This function must not be called with an empty string. If the length of the string is `1`, it will return the string. Otherwise, this function assigns the first character in the string to a local variable m and calls `f` for every other character in the string, with `m` and that character as parameters. The value which `f` returns will then be assigned to `m` for the next iteration. Returns the final value of `m`.
 - `string.reduceright(s:string, f:function):anything` This works exactly like `string.reduceleft`, just that it starts at the end of the string.
 - `string.split(s:string, sep:string or number or nil):list` This function splits the string whenever it encounters the specified separator, returning a list of every part of the string. If `sep` is a number, it will split the string into chunks of the specified length.
 - `string.iter(s:string)` This functions returns an iterator over the string `s`, so you can iterate through the characters of the string using `for index, char in string.iter(s) do ... end`.

### Wrapped tables
These are the functions you can call on wrapped tables. `$()` represents a wrapped list or map, `$l()` represents a list, `$i()` represents an iterable.
 - `$():concat(sep:string, i:number, j:number):string` This works exactly like `table.concat`.
 - `$():foreach(f:function)` This works exactly like `string.foreach`, just that it will iterate through each key/value pair in the table.
 - `$():map(f:function):list or map` This works exactly like `string.map`, just that it will iterate through each key/value pair in the table.
 - `$():flatmap(f:function):list` This works like `$():map(f):flatten`, meaning that it will apply a function that returns tables and afterwards try to flatten the results. See `$():map` and `$l():flatten`.
 - `$():filter(f:function):list or map` This works exactly like `string.filter`, just that it will iterate through each key/value pair in the table and will return a list if possible, a map otherwise.
 - `$():switch(funcs:function...)` This is equivalent to `switch($(), ...)`.
 - `$():fold(m:anything, f:function):anything` This works exactly like `$():foldleft`.
 - `$():foldleft(m:anything, f:function):anything` This works exactly like `string.foldleft`, just that it will iterate through each key/value pair in the table.
 - `$():foldright(m:anything, f:function):anything` This works exactly like `$():foldleft`, just that it starts iterating at the end of the list.
 - `$():flip():list or map` Swaps every key in the table with its value and returns a new wrapped table.
 - `$():find(f:function):anything` This returns the first element of the table that `f` returns `true` on.
 - `$():contains(val:anything):boolean` This returns true if the table contains `val`.
 - `$():containskey(key:anything):boolean` This returns true if the table has [key] mapped to any value that is not `nil`.
 - `$():count(f:function):number` This returns the amount of elements in the table that `f` returns `true` on.
 - `$():exists(f:function):boolean` This returns true if `f` returns `true` on any of the elements.
 - `$():forall(f:function):boolean` This returns true if `f` returns `true` on every element in the table.
 - `$():shallowcopy()` This works exactly like `table.shallowcopy`.
 - `$():call(f:function, ...):anything` This calls `f` with the internal table and any added parameters as arguments. Returns the value `f` returns. If `f` returns a table or string, it will be wrapped before being returned.
 - `$():clear():list or map` This will remove every value stored in the table and return the table.
 - `$():keys():list` Returns a new list containing all the keys stored in the table. Will be in order if this is a list.
 - `$():values():list` Returns a new list containing all the values stored in the table. Will be in order if this is a list.
 - `$l():index(f:function):number` This returns the index of the first element of the table that `f` returns `true` on.
 - `$l():drop(n:number):list` This function will remove the first `n` entries from the list and return a list with the dropped entries.
 - `$l():dropright(n:number):list` This function will remove the last `n` entries from the list and return a list with the dropped entries.
 - `$l():dropwhile(f:function):list` This works exactly like `string.dropwhile`, just that it will iterate through each key/value pair in the table and will return a list with the dropped entries.
 - `$l():take(n:number):list` This function will take the first `n` entries from the list and return a list with the taken entries.
 - `$l():takeright(n:number):list` This function will take the last `n` entries from the list and return a list with the taken entries.
 - `$l():takewhile(f:function):list` This works exactly like `string.takewhile`, just that it will iterate through each key/value pair in the table and will return a list with the taken entries.
 - `$l():slice(start:number or nil, stop:number or nil [, step:number or nil]):list` This function will slice a specific range of indices out of the list and return it, starting at index `start` and stopping at `stop` with a step size of `step`. `step` must not be 0 but can be negative. `start` will default to `1` if it is `nil` or `0`, `stop` will default to the length of the list. Negative values for `start` or `stop` are interpreted as indexing backwards, from the end of the list.
 - `$l():splice(index:number [, replacements...]):list` This removes the item at the given index, and, if replacements are given, inserts those in place.
 - `$l():reduce(f:function):anything` This works exactly like `$l():reduceleft`.
 - `$l():reduceleft(f:function):anything` This function must not be called with an empty list. If the length of the list is `1`, it will return the only value in the list. Otherwise, this function assigns the first entry in the list to a local variable m and calls `f` for every other value in the list, with `m` and that value as parameters. The value which `f` returns will then be assigned to `m` for the next iteration. Returns the final value of `m`.
 - `$l():reduceright(f:function):anything` This works exactly like `$l():reduceleft`, just that it starts at the end of the list.
 - `$l():reverse():list` This function will invert the list so that the last entry will be the first one etc.
 - `$l():flatten():list` This works exactly like `table.flatten`.
 - `$l():zip(other:list or table or function):list` This will merge the other table (which has to be an ipairs-valid list) or list into itself if both lists have the same length, in the pattern `{{t1[1], t2[1]}, {t1[2], t2[2]}, ...}`. If `other` is a function or wrapped function, it will call it once per iteration and merge the returned value in the described pattern.
 - `$i():collect():list` This function will iterate through the iterable and add every returned element to a list which it will return.

### Wrapped strings
Wrapped strings or stringslists can mostly be seen as lists and have most of the functions wrapped tables have (including `drop`, `dropwhile` and `reverse`).
Functions they do not have are `concat`, `find`, `flatten`, `zip`, `containskey` and `flip`. All variations of `drop` and `take` will return strings, `filter`, `slice` and `reverse` will return stringlists, and they have two new functions:
 - `$s():split(sep:string or nil):list` This works exactly like `string.split`.
 - `$s():iter()` This works exactly like `string.iter`.

# Running Selene
This is an example for a Selene loader for the standard Lua interpreter. Make sure to add the folder called "selene" to some folder that exists in the package path.
```lua
local selene = require("selene")
selene.load(nil, true)
```
Keep in mind that Selene is unable to parse any special syntax before `selene.load` is called (with live mode turned on), meaning the file it is being loaded in must not contain any Selene code itself when it is run.

The table which `require("selene")` returns provides a few values.
 - `selene.load([env:table [, liveMode:boolean]])` Initializes Selene.First argument is the environment to initialize in, `_G` by default. The second argument specifies whether the parser should be loaded too (to make Selene compile directly from source without you having to compile the code first using selene.parse). An alternative is to set `_G._selene.doAutoload` to `true` before you `require` the library.
 - `selene.unload()` This removes the functions Selene adds to standard libraries like string and table again. It also disables the parser if it was enabled.
 - `selene.parse(chunk:string [, stripcomments:boolean]):string` This parses the given chunk of Selene or Lua code into pure Lua code. Use this for implementing compilers in case you are not going to use live mode. `stripcomments` is true by default and will, if `true`, remove all comments from the compiled code to reduce parsing time (it will keep line numbers accurate).
 - `selene.isLoaded():boolean` Returns `true` if Selene is currently loaded.
 - `selene.parser` This is the parser object that Selene uses.

# How Live Mode works
If liveMode is turned on, Selene will intercept `_G.load` to parse code going through it before directing it to the actual `load` function. Since Selene is written purely in Lua, it is not possible to intercept on a lower level. If other code loading functions that do not call `load` themselves exist in your implementation, you might want to replace them with an implementation that redirects to `load` yourself, or make it call `selene.parse`. For more information, please refer to the implementation of `load` in Selene.
