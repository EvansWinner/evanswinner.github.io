---
title: Set Operations with Bash
subtitle: ~ a demonstration ~
author: Evans H. Winner
date: Thursday, April 12, 2018
---

This is a demonstration of the use of the `bash` shell to
perform line-wise set operations on files — that is, set
union, intersection, *et cetera*.

I am sufficiently certain that there are other examples of
the same sort of thing out there, many probably better, that
I haven‘t even bothered to try Googling for it. I mainly
present this as A) an example of a few of the nicer features
of `bash`, and B) as a little demonstration of the program I
used for post-processing the file,
[Kallychore](https://github.com/EvansWinner/kallychore).


The plain text source for this file is at
[http://evanswinner.github.io/sets.kc](http://evanswinner.github.io/sets.kc). If
you would like to play with the `bash` functions defined
here, you can install Kallychore and then download the
source with:
 
    $ curl evanswinner.github.io/sets.kc > sets.kc

Then source the file with

    $ source <(kallychore sets.kc)

Then the functions will be defined in your current session.

So, before we begin, let‘s generate four files with test
data, a.txt, b.txt, c.txt, and d.txt. We will also create an
empty file, E, to be an empty set.

```bash
#### Code Cell Start ##########
IFS=$'\n'
for i in 2 1 3 1 4; do echo $i >> a.txt; done
for i in 3 4 5 6; do echo $i >> b.txt; done
for i in 4 5 4 5; do echo $i >> c.txt; done
for i in 1 3 3 3 3 3 3 5 7 9; do echo $i >> d.txt; done
touch E
###############################
```
~~~~~
~~~~~

Let’s display the data once, just so you see that it’s
really there. As long as we’re doing that, we might as well
format it nicely in little tables with headers. We will use
a semi-colon to put two commands on a single line, which is
often a bad idea, but which seems best here, as it keeps
related things together and makes it clear what is being
done.

```bash
#### Code Cell Start ##########
echo -e "\nFile a.txt\n==========" ; cat a.txt
echo -e "\nFile b.txt\n==========" ; cat b.txt
echo -e "\nFile c.txt\n==========" ; cat c.txt
echo -e "\nFile d.txt\n==========" ; cat d.txt
###############################
```
~~~~~

File a.txt
==========
2
1
3
1
4

File b.txt
==========
3
4
5
6

File c.txt
==========
4
5
4
5

File d.txt
==========
1
3
3
3
3
3
3
5
7
9
~~~~~

First, our concept of a set here is a file, and our concept
of a set member is a line in a file. This means that we
cannot have any sort of notion of sets containing other
sets, only a single level of set containing things.

Also, a set, properly speaking, does not have duplicate
members, so the first thing we will need to do is to make
our “random” data into an actual set, by removing any
duplicates. This is easy to do. We just sort the data using
`sort` and then pipe that to `uniq`. `uniq` will remove all
duplicate lines that are next to each other. Before that can
work, though, the duplicates have to *be* next to each
other. That’s why we sort the lines first. The resulting
data are now sorted. The members of a set are not, *qua* set
members, ordered; but it won’t hurt anything to leave them
sorted in lexicographical order.

So, to do this to file a.txt, it would look like this:

    $ sort a.txt | uniq

But let‘s wrap that logic into a function — in proper Unix
style, we‘ll give it the brief and cryptic name,
`mkset`. And while we‘re at it, why not just glom together
the lines from as many files as we want all at once. We‘ll
use the variable $@ to mean “all the files we specify.”

```bash
#### Code Cell Start ##########
mkset () { sort $@ | uniq; }
###############################
```
~~~~~
~~~~~

Let‘s try it out, and while we‘re at it, we‘ll format that
output too. We don‘t need to do all of them for you to get
the idea, I trust.

```bash
#### Code Cell Start ##########
echo -e "Set C\n=====" ; mkset c.txt
echo -e "\nSet D\n=====" ; mkset d.txt
###############################
```
~~~~~
Set C
=====
4
5

Set D
=====
1
3
5
7
9
~~~~~

Ok, last thing. Many of the functions we define below are
going to want to have a file as input, and using process
substitution using `mkset` doesn’t always work easily. So,
while I generally detest generating temporary files, we’re
going to generate set versions of all our test files and
call them A, B, C, and D. E, the empty set, we already
created.

```bash
#### Code Cell Start ##########
mkset a.txt > A ; mkset b.txt > B
mkset c.txt > C ; mkset d.txt > D
###############################
```
~~~~~
~~~~~

Ok, so now we have a function that will make a set out of
the lines in any text file. The astute reader may have
noticed something here. Since we are able to make a set out
of any number of files specified on the command line, we’ve
basically created our first set operation for free — set
Union. But to keep things nice, we’ll make a new function
with the name `∪` by simply defining it as `mkset`. Note
that that is a Unicode Union character, not a letter "U."
You can have Unicode function names in `bash`. Cool, eh?

```bash
#### Code Cell Start ##########
∪ () { mkset $@; }
###############################
```
~~~~~
~~~~~

Now we can take the union, *A ∪ B* :

```bash
#### Code Cell Start ##########
∪ A B 
###############################
```
~~~~~
1
2
3
4
5
6
~~~~~

And in fact, we can take the union, *A ∪ B ∪ C ∪ D* :

```bash
#### Code Cell Start ##########
∪ A B C D 
###############################
```
~~~~~
1
2
3
4
5
6
7
9
~~~~~

Now, from a practical point of view, we probably want to
have a function that we can give a file, and have the
function tell us whether that file is a set or not. We can
use the `cmp` command for that. Let’s give it two bits of
data: the file we want to check, and a version of that same
file that we’ve fed to `mkset`. If the two are the same,
then we know we’ve got a set. Here we can use a nice feature
of the shell, called process substitution (see
[here](http://tldp.org/LDP/abs/html/process-sub.html) for
more information). In the arguments where file names would
normally go in a call to `cmp` we instead send the result of
sorting the file for the first argument, and calling `mkset`
for the second argument.

The `cmp` command compares a file byte by byte. If we use
the `-s` flag, it will not print any output, but will only
send an error code to `/dev/stderr` depending on whether the
files are identical or not. If the data are identical, then
the file is a set; if not, then not.

We could name our function `isset`, but the Unix hacker in
me can’t stand the duplication of the letter “s” — so let’s
call it `iset`.

Note that an empty file should read as a set — an empty set,
but still a set as we are using the concept here. We're not
going to handle the case where the file doesn't exist. That
is the user’s problem.

```bash
#### Code Cell Start ##########
iset () { cmp -s <(sort $1) <(mkset $1); }
###############################
```
~~~~~
~~~~~

Recall that file a.txt contains 5 objects — “2”, “1”, “3”,
“1”, and “4” — but that only 4 of them are unique, so file
a.txt is not a set. File B, on the other hand, is a
set. Let’s test our function `iset`. 

Ok, let’s try it:

```bash
#### Code Cell Start ##########
iset a.txt && echo T || echo F
iset B && echo T || echo F
###############################
```
~~~~~
F
T
~~~~~

What about an empty set?

```bash
#### Code Cell Start ##########
iset E && echo T || echo F
###############################
```
~~~~~
T
~~~~~

And should a non-existent file send an error?

```bash
#### Code Cell Start ##########
iset F && echo T || echo F
###############################
```
~~~~~
T
~~~~~

Evidently not. Well, I did say providing a legitimate file
name was the user‘s problem.

Anyway, great. But can we feed the result of making a set
into `iset` and get *T*?

```bash
#### Code Cell Start ##########
iset <(mkset A)
mkset A | iset 
###############################
```
~~~~~
~~~~~

Nothing. No. It‘s a problem I haven‘t solved.

But as long as we‘re thinking about it, we might as well
define a function that will tell us whether something is an
empty set:

```bash
#### Code Cell Start ##########
∅ () { if [ -f $1 -a ! -s $1 ]; then true; else false; fi; }
###############################
```
~~~~~
~~~~~

Let’s test:

```bash
#### Code Cell Start ##########
∅ A && echo T || echo F
# ==> F — because this is a non-empty set

∅ E && echo T || echo F
# ==> T — because the file exists, but is empty

∅ F && echo T || echo F
# ==> F — because this file does not exist
###############################
```
~~~~~
F
T
F
~~~~~

We probably want to know the cardinality of our sets. That
is trivially done with the `wc` command, but `wc`
unhelpfully does not have an option to shut up its extra
information it gives you, so we will have to filter it with
`cut` to cut the second column:

```bash
#### Code Cell Start ##########
crd () { wc -l $1 | cut -d " " -f 1; }
###############################
```
~~~~~
~~~~~
 
The cardinality of C, then, is:

```bash
#### Code Cell Start ##########
crd C
###############################
```
~~~~~
2
~~~~~

Wait, we had better check that the cardinality of the empty
set is *0*:

```bash
#### Code Cell Start ##########
crd E 
###############################
```
~~~~~
0
~~~~~

Okay, good. So, now we need a set intersection
function. This is simple if you know about the Unix `comm`
command. It is a little like `diff`, but simpler. It will
print out three columns, one with lines unique to the first
file you specify; the second with lines unique to the second
file you specify, and the third with lines common to
both. You can choose to suppress any of those columns, so
let’s suppress the first two and leave only the third. The
lines common to both files amount to the intersection of the
two sets.

```bash
#### Code Cell Start ##########
∩ () { comm -12 <(mkset $1) <(mkset $2); }
###############################
```
~~~~~
~~~~~

To test it, let’s try *A ∩ B* :

```bash
#### Code Cell Start ##########
∩ A B 
###############################
```
~~~~~
3
4
~~~~~

Relative complement, or set difference, between A and B,
that is *B* ∖ *A*, which gives that which is unique to *B*,
is done the same way, only we suppress different columns in
`comm`’s output. For the sake of consistency here we will
use the Unicode SET MINUS character. This is not a
backslash. It would be a bit dangerous to use normally, but
in this case, I‘ll let it slide:

```bash
#### Code Cell Start ##########
∖ () { comm -13 $2 $1; }
###############################
```
~~~~~
~~~~~

Testing *A* ∖ *B*:

```bash
#### Code Cell Start ##########
∖ A B 
###############################
```
~~~~~
1
2
~~~~~

And *B* ∖ *A*:

```bash
#### Code Cell Start ##########
∖ B A 
###############################
```
~~~~~
5
6
~~~~~

Now, we might like to know whether a line is a member of a
set. We can use `grep` in almost the same way that we used
`cmp` (although for some reason the flag to keep `grep`
quiet is `-q` (presumably for “quiet”) instead of `-s`
(presumably for “silent”)). We grep for the line. If it’s in
the file, then great, it is a set member. We don’t even have
to use `mkset` on the argument, because if it’s in the
original file, it’s in the set.

```bash
#### Code Cell Start ##########
∈ () { grep -q "^$1$" $2 && true || false; }
###############################
```
~~~~~
~~~~~

Again, to test it, let’s see if *2 ∈ A*

```bash
#### Code Cell Start ##########
∈ 2 A && echo T || echo F
###############################
```
~~~~~
T
~~~~~

Yep. How about if *3 ∈ C*:

```bash
#### Code Cell Start ##########
∈ 3 C && echo T || echo F 
###############################
```
~~~~~
F
~~~~~

Nope. As expected.

So the obious next thing to do is check to see if one set is
a subset of another. Let‘s get tedious about it...

```bash
#### Code Cell Start ##########
# Subset
⊆ () {
  ret=T
  while read e
  do
    if [ ! $(grep "$e" "$2") ]
    then
      ret=F
    fi
  done < $1
  if [ "$ret" == "T" ]; then true; else false; fi
}

# Proper superset
⊇ () { ⊆ $2 $1; }

# Set equality
seteq () { ⊆ $1 $2 && ⊆ $2 $1 && true || false; }

# Proper subset
⊂ () { ⊆ $1 $2 && ! seteq $1 $2 && true || false; }

# Superset
⊃ () { ⊂ $2 $1; }

# Not a superset and not a subset. I mean, let's be REALLY
# tedious here...
⊅ () { ⊃ $1 $2 && false || true; }
⊄ () { ⊂ $1 $2 && false || true; }
###############################
```
~~~~~
~~~~~

Let‘s test it out with some semi-random tests:

```bash
#### Code Cell Start ##########
⊆ A B && echo T || echo F     # ==> F
seteq A A && echo T || echo F # ==> T (a set should = itself)
seteq A B && echo T || echo F # ==> F
⊆ C B && echo T || echo F     # ==> T
⊂ C B && echo T || echo F     # Also ==> T
⊂ B C && echo T || echo F     # ==> F
⊃ A A && echo T || echo F     # ==> F
⊇ A B && echo T || echo F     # ==> F
⊅ A A && echo T || echo F     # ==> T
⊄ C B && echo T || echo F     # ==> T
###############################
```
~~~~~
F
T
F
T
T
F
F
F
T
T
~~~~~

Ok, play time is over. Let’s see if we can generate a cross
product (more properly, I guess, a “cartesian product”) of
two sets now. We will have to resort to loops. I hate
[stinking loops](http://www.nsl.com/), but what can you do?
It‘s `bash`.

```bash
#### Code Cell Start ##########
## $1 will be set 1
## $2 will be set 2
## Optional arugment $3 is a delimiter for the output (like
## an opening bracket)
## Optional argument $4 will be a separator between elements
## of the pairs)
## Optional argument $5 will be an ending delimiter (like a
## closing bracket)
## Optional arguments $6 and $7 will be printed once first
## (for a bracket if you want) and then last.
× () {
  echo -n $6
  while read i
  do
    while read j
    do
      if [ "$i" != "" ] && [ "$j" != "" ]
      then
        echo $3$i$4$j$5;
      fi
    done < $2
  done < $1
  if  [ "$7" != "" ]; then echo $7; fi;
}
###############################
```
~~~~~
~~~~~

Let's try it out with *A × B* :

```bash
#### Code Cell Start ##########
× A B
###############################
```
~~~~~
13
14
15
16
23
24
25
26
33
34
35
36
43
44
45
46
~~~~~

There is no space between the elements. Let's do it again,
but add the formatting. We'll also pipe it to `fmt` so that
we don't have to have each set take up a whole line.

```bash
#### Code Cell Start ##########
× A B "(" "," ")" "{" "}" | fmt -w 60 
###############################
```
~~~~~
{(1,3) (1,4) (1,5) (1,6) (2,3) (2,4) (2,5) (2,6) (3,3)
(3,4) (3,5) (3,6) (4,3) (4,4) (4,5) (4,6) }
~~~~~

Strictly, we should have commas between each pair in the
set, but that would make it harder to nest calls to the ×
function. By nesting, we can get the cross product of more
than just two sets. In fact, let's check to see if it works
with all four sets — and heck, let's throw in E, the empty
set, too, to make sure it works:

```bash
#### Code Cell Start ##########
× <(× <(× <(× A B "" "," "") C "" "," "") D "" "," "") \
   E "(" "," ")" "{" "}"
###############################
```
~~~~~
{}
~~~~~

Whoops! Well, it *does* work, because the cross product of
any set with the empty set *is* the empty set. So let's just
try *A*, *B*, *C*, and *D*:

```bash
#### Code Cell Start ##########
× <(× <(× A B "" "," "") C "" "," "") D "(" "," ")" "{" "}" \
   | fmt -w 60 
###############################
```
~~~~~
{(1,3,4,1) (1,3,4,3) (1,3,4,5) (1,3,4,7) (1,3,4,9)
(1,3,5,1) (1,3,5,3) (1,3,5,5) (1,3,5,7) (1,3,5,9) (1,4,4,1)
(1,4,4,3) (1,4,4,5) (1,4,4,7) (1,4,4,9) (1,4,5,1) (1,4,5,3)
(1,4,5,5) (1,4,5,7) (1,4,5,9) (1,5,4,1) (1,5,4,3) (1,5,4,5)
(1,5,4,7) (1,5,4,9) (1,5,5,1) (1,5,5,3) (1,5,5,5) (1,5,5,7)
(1,5,5,9) (1,6,4,1) (1,6,4,3) (1,6,4,5) (1,6,4,7) (1,6,4,9)
(1,6,5,1) (1,6,5,3) (1,6,5,5) (1,6,5,7) (1,6,5,9) (2,3,4,1)
(2,3,4,3) (2,3,4,5) (2,3,4,7) (2,3,4,9) (2,3,5,1) (2,3,5,3)
(2,3,5,5) (2,3,5,7) (2,3,5,9) (2,4,4,1) (2,4,4,3) (2,4,4,5)
(2,4,4,7) (2,4,4,9) (2,4,5,1) (2,4,5,3) (2,4,5,5) (2,4,5,7)
(2,4,5,9) (2,5,4,1) (2,5,4,3) (2,5,4,5) (2,5,4,7) (2,5,4,9)
(2,5,5,1) (2,5,5,3) (2,5,5,5) (2,5,5,7) (2,5,5,9) (2,6,4,1)
(2,6,4,3) (2,6,4,5) (2,6,4,7) (2,6,4,9) (2,6,5,1) (2,6,5,3)
(2,6,5,5) (2,6,5,7) (2,6,5,9) (3,3,4,1) (3,3,4,3) (3,3,4,5)
(3,3,4,7) (3,3,4,9) (3,3,5,1) (3,3,5,3) (3,3,5,5) (3,3,5,7)
(3,3,5,9) (3,4,4,1) (3,4,4,3) (3,4,4,5) (3,4,4,7) (3,4,4,9)
(3,4,5,1) (3,4,5,3) (3,4,5,5) (3,4,5,7) (3,4,5,9) (3,5,4,1)
(3,5,4,3) (3,5,4,5) (3,5,4,7) (3,5,4,9) (3,5,5,1) (3,5,5,3)
(3,5,5,5) (3,5,5,7) (3,5,5,9) (3,6,4,1) (3,6,4,3) (3,6,4,5)
(3,6,4,7) (3,6,4,9) (3,6,5,1) (3,6,5,3) (3,6,5,5) (3,6,5,7)
(3,6,5,9) (4,3,4,1) (4,3,4,3) (4,3,4,5) (4,3,4,7) (4,3,4,9)
(4,3,5,1) (4,3,5,3) (4,3,5,5) (4,3,5,7) (4,3,5,9) (4,4,4,1)
(4,4,4,3) (4,4,4,5) (4,4,4,7) (4,4,4,9) (4,4,5,1) (4,4,5,3)
(4,4,5,5) (4,4,5,7) (4,4,5,9) (4,5,4,1) (4,5,4,3) (4,5,4,5)
(4,5,4,7) (4,5,4,9) (4,5,5,1) (4,5,5,3) (4,5,5,5) (4,5,5,7)
(4,5,5,9) (4,6,4,1) (4,6,4,3) (4,6,4,5) (4,6,4,7) (4,6,4,9)
(4,6,5,1) (4,6,5,3) (4,6,5,5) (4,6,5,7) (4,6,5,9) }
~~~~~

Is that the right size? Let's check the cardinality:

```bash
#### Code Cell Start ##########
× <(× <(× A B "" "," "") C "" "," "") D "(" "," ")" | crd 
###############################
```
~~~~~
160
~~~~~

Well, what *should* the cardinality be? It should be *|A| ×
|B| × |C| × |D|*. Let‘s find that value using process
substitution, and a little script for `bc`, the Unix bench
calculator:
 
```bash
#### Code Cell Start ##########
echo "$(crd A) * $(crd B) * $(crd C) * $(crd D)" | bc 
###############################
```
~~~~~
160
~~~~~

Yay!

Ok, well, anything else to do? I suppose we should see if we
can make a function to generate the power set of a given
set.

Lol. Just kidding.

No, not kidding. Like the Man said, “If it‘s worth doing,
it‘s worth being completely ridiculous about it.”

The basic strategy is this. For a set *S* of cardinality
*n*, there will be *2ⁿ* subsets within the powerset. So if
we generate a list of binary integers from *0* to *2ⁿ - 1*
we can treat the *i*th digit of the *j*th binary number as
indicating whether the *i*th element of S is going to be
present in the *j*th element of the power set. Whew. That’s
confusing. Wait, is it even right? Let’s begin
again. Basically, we generate the list of *2ⁿ* binary
numbers, then use each as a bitmask on the original
set. Where there’s a *1*, we include that element from the
original set S in the new subset, and where there is a *0*,
we don’t. So, the first bitmask will be all zeros. So that
will result in the empty set (which is always one of the
elements of a power set). The *2ⁿ*th bitmask will be all
ones. That means for that one we will include *all* of the
elements of the original set, which is also always one
element of a power set.

So, let’s start. Here’s a function to get a binary
representation of a given integer:

```bash
#### Code Cell Start ##########
dec_to_bin () { echo "obase=2; $1" | bc; }
###############################
```
~~~~~
~~~~~

Next we’ll need a function to zero-pad a number to a given
length. We will use `echo`’s more powerfull big brother,
`printf`, which lets us do string formatting.

```bash
#### Code Cell Start ##########
zero_pad () { printf "%0${2}d\n" $1; }
###############################
```
~~~~~
~~~~~

Now, let’s combine the previous two and get a binary mask
ish thingie (ultimately) the length of the cardinality of
the set. $1 (the first parameter) will be *n* — that is, the
number to pad, and $2 will be the length to pad out to.

```bash
#### Code Cell Start ##########
make_mask () { zero_pad $(dec_to_bin $1) $2; }
###############################
```
~~~~~
~~~~~

Again, there are *2ⁿ* elements in a power set, but we will
be counting from zero, so let’s have a little function to
calculate *2ⁿ - 1* for us:

```bash
#### Code Cell Start ##########
two_to_the_n_minus_1 () { echo "2 ^ $1 - 1" | bc; }
###############################
```
~~~~~
~~~~~

Ok, now we need to be able to generate a list of those masks
— a list of strings representing binary numbers, one for
each possible subset of the set with cardinality *n*. I tend
to love little temporary variables as much as I like
explicit loops, but it seems like a good idea here:

```bash
#### Code Cell Start ##########
make_masks () {
  local n=$(two_to_the_n_minus_1 $1)
  for i in $(seq 0 $n)
  do
    make_mask $i $1
  done
}
###############################
```
~~~~~
~~~~~

We need to be able to get the *n*th line of the input which,
in the case of sets, is the *n*th element. Whatever. You
know what I mean. Really.  n=$2 The name of the set (the
file) will be $1 and which element (*n*) will be $1.

```bash
#### Code Cell Start ##########
nth_element () { head -$2 $1 | tail -1; }
###############################
```
~~~~~
~~~~~

We need to be able to get the nth character from one of our
bit masks, to find out whether the coresponding element goes
into our set. *n* will be parameter $2 and the mask we are
looking in will be $1. We can use `bash`’s `expr` command
with its `substr` sub-command to do this. Look it up if you
don’t believe me.

```bash
#### Code Cell Start ##########
nth_character () { expr substr "$1" "$2" 1; }
###############################
```
~~~~~
~~~~~

Okay, this is where the magic happens. There is some cruft
in there to nicely format it with curly braces and commas.

$2 is the set, and $1 is the bitmask.

```bash
#### Code Cell Start ##########
make_subset () {
    startflag=0 # For comma separator. We don't want one
                # before the first element
    echo -n "{"
    cardinality=$(crd $2)
    for i in $(seq 1 $cardinality)
    do
        if (( $(nth_character "$1" "$i") == "1" ))
        then
            if (( "$startflag" == "1" )) && (( "$i" <= "$cardinality" ))
            then
                echo -n ","
            fi
            echo -n $(nth_element $2 "$i"); startflag=1;
        fi
    done
    echo "}"
}
###############################
```
~~~~~
~~~~~

Finally, we can write our `power_set` function, which just
takes the set, generates the list of bitmasks, and then
loops over the bitmasks against the set.

```bash
#### Code Cell Start ##########
power_set () {
  for mask in $(make_masks $(crd $1))
  do
    make_subset $mask $1
  done
}
###############################
```
~~~~~
~~~~~

Ok, so let’s try it:

```bash
#### Code Cell Start ##########
power_set A
###############################
```
~~~~~
{}
{4}
{3}
{3,4}
{2}
{2,4}
{2,3}
{2,3,4}
{1}
{1,4}
{1,3}
{1,3,4}
{1,2}
{1,2,4}
{1,2,3}
{1,2,3,4}
~~~~~

Cool. So, obviously the number of lines output by this
process (not to mention the time it takes to run) will scale
at the rate of *O(2ⁿ)*, where n is the cardinality of the
input set. Let’s run it again with the union of all our
sets, but instead of actually displaying the output, let’s
just check that the cardinality of the output is *2ⁿ*:

```bash
#### Code Cell Start ##########
∪ A B C D E > F
crd <(power_set F)
###############################
```
~~~~~
256
~~~~~

*F* (the union of *A*, *B*, *C*, *D* and *E*) has the
following cardinality:

```bash
#### Code Cell Start ##########
crd F
###############################
```
~~~~~
8
~~~~~

So the cardinality of the power set should be *2ⁿ = 2⁸ =
256*. So. There you go.

Well, I hope you’ve gotten a laugh out of all this. I
certainly got a tear or two. Have a better one.


# Colophon

The plain text source for this file is at
[http://evanswinner.github.io/sets.kc](http://evanswinner.github.io/sets.kc).

This file was created with GNU Emacs and post-processed with
[Kallychore](https://github.com/EvansWinner/kallychore) and
Pandoc.

```bash
#### Code Cell Start ##########
echo "This file generated on `date` on `hostname`." ; echo
make_recipe sets.html ; echo
echo "Versions of programs used:"
whatver SYSTEM bash bc cmp comm emacs fmt fold grep \
        kallychore make pandoc sort touch uniq wc whatver \
	| fold -w60
###############################
```
~~~~~
This file generated on Fri Aug 26 09:49:01 MDT 2022 on compensation.

The Makefile command line was:
kallychore -m sets.kc | \
          bash > sets.md     && \
          pandoc -s -f markdown+backtick_code_blocks \
            --highlight-style=tango -t html \
            --include-in-header=portfolio.css -o sets.html sets.md

Versions of programs used:
Linux 5.15.0-41-generic #44-Ubuntu SMP Wed Jun 22 14:20:53 U
TC 2022 x86_64 x86_64 x86_64 GNU/Linux
GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)
bc 1.07.1
cmp (GNU diffutils) 3.8
comm (GNU coreutils) 8.32
GNU Emacs 29.0.50
fmt (GNU coreutils) 8.32
fold (GNU coreutils) 8.32
grep (GNU grep) 3.7
kallychore version (git revision) 31
GNU Make 4.3
pandoc 2.9.2.1
sort (GNU coreutils) 8.32
touch (GNU coreutils) 8.32
uniq (GNU coreutils) 8.32
wc (GNU coreutils) 8.32
whatver version (git revision) 19
~~~~~

Don't let's forget to clean up after ourselves.

```bash
#### Code Cell Start ##########
rm -f a.txt b.txt c.txt d.txt A B C D E
###############################
```
~~~~~
~~~~~

------
© 2018 Evans H Winner.

Evans Winner is a Professional IT Minion in Golden, Colorado, and
intends to keep on writing things like this until he manages to get a
decent job. ([LinkedIn](https://www.linkedin.com/in/evanswinner/),
[email](mailto:evans.winner@gmail.com),
[webpage](http://evanswinner.github.io/portfolio.html))
