---
title: A K-Nearest Neighbors Classifier in Bash
author: Evans H. Winner
date: July 2019
---


Introduction
============

Here is an implementation of the classification version of the
k-Nearest Neighbors algorithm using "pure" Bash. That is, Bash, plus
standard Unix tools like sed, echo, and bc. In fact, bc is as close as
we get to cheating, since we have to use it to do some basic
mathematics. We also use curl to download our dataset.

Although the code attempts to be as general is possible, I've only
tested it really on the famouse Iris dataset.

So, let's launch into it. We will be using Euclidean distance between
points, as it is the simplest, and this is just a proof of concept. In
an N-dimensional space, we use an N-dimensional extension to the
Pythagorean theorem, where distance, d is defined as the square root
of a₁² + a₂² + ⋯ aₙ², and aₓ is the the difference between two values
of a given variable (or axis).

So, for example, if we have the following two data points:

  1 2 3
  2 3 4

then the Euclidian distance between them will be the square root of
(1-2)² + (2-3)² + (3-4)², which is the square root of 3, ≅ 1.73.

We need to choose a value for k for our algorithm. We can change it
later and see what works best, but for the moment, let's use 5.

```bash
#### Code Cell Start ##########
declare -i k=5 # set for each run or whatever
###############################
```
~~~~~
~~~~~

Now, we will need a few basic mathematical functions which we'll
define using the Unix bc command:

```bash
#### Code Cell Start ##########
#export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

## `arith' takes a value, an operator, and another value. We'll use to
## to define a couple of other math functions.
arith() { echo "scale=4; $1 $2 $3" | bc -l | sed 's/^\./0./'; }

## Based on this, we can define functions to calculate the square of a
## number, the square root, and then a sum of squares.
sqr() { arith $1 '*' $1; }
sqrt() { echo "scale=4; sqrt($1)" | bc -l | sed 's/^\./0./'; }
sum_of_squares() {
  local a=0 # result
  for s in $*
  do
    a=$(arith $a '+' $(sqr $s))
  done
  echo $a
}
###############################
```
~~~~~
~~~~~

I don't like using temporary files, but when you're using Bash, it
sometimes saves a lot of hassle. Let's define what we're going to need
here:

```bash
#### Code Cell Start ##########
declare data="iris.dat"
declare data_normalized="iris_normalized.dat"
declare training="iris_training.dat"
declare testing="iris_testing.dat"
declare tmp_file="tmp.dat"
###############################
```
~~~~~
~~~~~

The next step is to get the data:

```bash
#### Code Cell Start ##########
declare url=https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data
# Get it only if we don't alreayd have it:
[ -f $data ] || curl -s $url > $data 
###############################
```
~~~~~
~~~~~

Let's check to make sure the raw data is what we think it is:

```bash
#### Code Cell Start ##########
head -5 $data
###############################
```
~~~~~
5.1,3.5,1.4,0.2,Iris-setosa
4.9,3.0,1.4,0.2,Iris-setosa
4.7,3.2,1.3,0.2,Iris-setosa
4.6,3.1,1.5,0.2,Iris-setosa
5.0,3.6,1.4,0.2,Iris-setosa
~~~~~

Ok. Good, so then we have to clean the data a little to get it into a
format we can use. The file comes with blank lines, which the later
code won't like, so let's clean that up first:

```bash
#### Code Cell Start ##########
remove_blanks() {
  sed -i "/^$/d" $1
}
remove_blanks $data # remove blank lines
###############################
```
~~~~~
~~~~~

We also need to change from comma-delimted to space delimited:

```bash
#### Code Cell Start ##########
sed -i "s/,/ /g" $data # change to space delimited
###############################
```
~~~~~
~~~~~

The data are going to be in the form of observations, each of which is
an m-length vector. We'll need to know the value of m later:

```bash
#### Code Cell Start ##########
# Assuming a blank space for column separator, this returns the number
# of columns in a dataset
cols() {
  local f=$1
  head -n1 $f | tr ' ' '\n' | wc -l
}
declare -i vector_len=$(($(cols $data) - 1))
###############################
```
~~~~~
~~~~~

We will also want to know some other information about our data for
normalization later, so let's write a basic routine to query the data
and tell us what we need. You’ll notice that there is a comment at the
start of the function that is a reminder of how to call the
function. I tend to find that the thing I forget most easily in a
language that doesn’t include function signitures is what I am
expected to pass to the function. Most of the more complex functions
here have similar comments at their starts. Anyway, the function to
get column information:

```bash
#### Code Cell Start ##########
# col_info file column_number max/min/range
col_info() {
  local seed=$(cut -d ' ' -f $2 $data | head -1) # get 1st value as seed
  local max=$seed; local min=$seed
  for n in $(cut -d ' ' -f $2 $1); do
    if (( $(arith $n '>' $max) )); then max=$n; fi
    if (( $(arith $n '<' $min) )); then min=$n; fi
  done
  if [[ "$3" == "range" ]]; then
    arith $max '-' $min;
  elif [[ "$3" == "min" ]]; then
    echo $min;
  else
    echo $max;
  fi
}
###############################
```
~~~~~
~~~~~

Then let’s use it to populate some variables we can access later:

```bash
#### Code Cell Start ##########
declare -a ranges
declare -a mins
for i in $(seq 1 $vector_len); do
  ranges[$i]=$(col_info $data $i range)
  mins[$i]=$(col_info $data $i min)
done
###############################
```
~~~~~
~~~~~

Now, the units of measurement for the various variables in our dataset
may not have any particular relation to one-another, and so one
variable may dominate the distance function, unless we normalize the
data first — that is we scale all the variables to a value between 0
and 1. That way, they’re all playing on a level field, so to speak.

```bash
#### Code Cell Start ##########
# normalize_data file vector_length 
normalize_data() {
  local file=$1; local len=$2
  while read l; do
    local -i field_count=0
    for v in $l; do
      field_count+=1
      if (( "$field_count" <= "$len" ))
      then
	printf "%s " \
	       $(arith $(arith $v '-' ${mins[${field_count}]}) '/' ${ranges[${field_count}]})
      else
	echo $v 
      fi					       
    done
  done < $file
}
###############################
```
~~~~~
~~~~~

Let’s run that now, and send it to a new file; then let’s once again
print out the first few lines to verify that we’ve got it right:

```bash
#### Code Cell Start ##########
normalize_data $data $vector_len > $tmp_file
mv -f $tmp_file $data_normalized
echo Normalized:
head -5 $data_normalized
###############################
```
~~~~~
Normalized:
0.2222 0.6250 0.0677 0.0416 Iris-setosa
0.1666 0.4166 0.0677 0.0416 Iris-setosa
0.1111 0.5000 0.0508 0.0416 Iris-setosa
0.0833 0.4583 0.0847 0.0416 Iris-setosa
0.1944 0.6666 0.0677 0.0416 Iris-setosa
~~~~~

Next, let’s “rotate” the data, to put the category of iris in each
observation in the first column, instead of the last. That way we
don’t have to worry about how many columns there are — we can just
operate on “every column from the second to the end,” which seems
easier.

```bash
#### Code Cell Start ##########
# rotate_cols file vector_length
rotate_cols() {
  local -i vector_length=$vector_len
  local file=$1
  paste -d " " <(cut -d " " -f $((vector_length + 1)) $file) \
	<(cut -d " " -f -$vector_len $file)
}
###############################
```
~~~~~
~~~~~

Once again, let’s apply the function to our data, and then print out
the first few lines to check it:

```bash
#### Code Cell Start ##########
rotate_cols $data_normalized $vector_len > $tmp_file
mv -f $tmp_file $data_normalized
echo Rotated:
head -5 $data_normalized
###############################
```
~~~~~
Rotated:
Iris-setosa 0.2222 0.6250 0.0677 0.0416
Iris-setosa 0.1666 0.4166 0.0677 0.0416
Iris-setosa 0.1111 0.5000 0.0508 0.0416
Iris-setosa 0.0833 0.4583 0.0847 0.0416
Iris-setosa 0.1944 0.6666 0.0677 0.0416
~~~~~

Now, with the kNN procedure, you don’t exactly need a training set to
run first. What you do is simply take a set of data that are already
classified, and then check a new observation by running it against all
the existing classified data. But we don’t have any new
observations. So what we’ll do to test the implementation is we will
pick out some “test” data from the whole dataset, and then we will run
them against the remaining data from the original dataset and see if,
or how many of them get classified in the same way that they came to
us.

So first, we need to know how many data points are in our original dataset:

```bash
#### Code Cell Start ##########
# How many observations?
obs() {
  local file=$1
  wc -l $file | cut -d " " -f 1;
}

declare -i number_of_observations=$(obs $data_normalized)
echo k=${k}, n=${number_of_observations}.
###############################
```
~~~~~
k=5, n=150.
~~~~~

Next, let’s write a function that will split our data into a “testing”
set and a “be tested against” set. We could write a complicated
randomization routine, but I think it will be just as good to simply
extract every n-th observation, with 1/n representing the proportion
of “test” data to extract from the dataset.

```bash
#### Code Cell Start ##########
# split_data every_nth_goes_to_testing_file input_file testing_output_file \
#            training_output_file
split_data() {
  local -i nth=$1; local infile=$2; local tst=$3; local trn=$4
  
  local -i l=0
  while read line
  do
    let l+=1
    if ((l % nth)); then {
      echo $line >> $trn
    } else {
      echo $line >> $tst
    }
    fi
  done < $infile
}
###############################
```
~~~~~
~~~~~

So, let’s do it. We’ll use the magic number 5 for our n:

```bash
#### Code Cell Start ##########
[ -f $training ] || split_data 5 $data_normalized $testing $training
###############################
```
~~~~~
~~~~~

Ok, so now, we need to actually write the core of the
procedure. First, of course, we need to be able to calculate the
pythagorean distance function:

```bash
#### Code Cell Start ##########
pyth() {
  sqrt $(sum_of_squares $*)
}
###############################
```
~~~~~
~~~~~

By the way, we'll need a utility to get just the n-th line of a dataset:

```bash
#### Code Cell Start ##########
# get_line file n
get_line() {
  local file=$1; local -i n=$2
  head -$n $file | tail -1
}
###############################
```
~~~~~
~~~~~

I guess this is where it gets real.

```bash
#### Code Cell Start ##########
deltas() {
  local args_len=$#; local -a data_vector
  for ((i=0;i<$vector_len;i++)); do
    data_vector[$i]=$1
    shift
  done
  for ((i=$vector_len;i<$args_len;i++)); do
    j=$(($i-$vector_len))
    query_vector[$j]=$1
    shift
  done
  for ((i=0;i<$vector_len;i++)); do
    arith ${data_vector[$i]} '-' ${query_vector[$i]}
  done  | fmt -60
}

# parse_record file line records-in-cut-format
parse_record() {
  local file=$1; local -i n=$2; local recs=$3
    cut -d ' ' -f $recs <(get_line $file $n)
}

# distances_from file vector_len query_value1 query_value2 ...
distances_from() {
  local file=$1; local -i rec=$2;
  shift 2

  local -i i=0
  while read;
  do
    i+=1
    echo $(pyth \
	     $(deltas \
		 $(parse_record \
		     $file $i 2-$(( $rec + 1 ))) $@ )) " " \
	 $(parse_record $file $i 1)
    
  done < $file
}

# vote training_file vector_len testing_file testing_record
vote() {
  local trn=$1; local -i len=$2; local tst=$3; local -i rec=$4;
  local -A cats
  while read line; do
    echo > $tmp_file
    cats[$line]=$(( ${cats[$line]} + 1 ))
  done < <(cut \
	     -d ' ' -f 2 \
	     <(distances_from $trn $len \
			      $(parse_record $tst $rec 2-) | \
		 sort | head -$k | sed 's/ \+/ /g'))
  for c in ${!cats[@]}; do echo ${cats[$c]} $c $(parse_record $tst $rec 1) >> $tmp_file; done
  remove_blanks $tmp_file
  sort -g -r $tmp_file | head -1 > $tmp_file.2
  cat $tmp_file.2
  unset cats
}

# training_file vector_len testing_file
votes() {
  local trn=$1; local -i len=$2; local tst=$3;
  local -i n=0
  while read; do
    let n+=1
    echo Instance $n
    vote $trn $len $tst $n
  done < $tst
}

votes $training $vector_len $testing
###############################
```
~~~~~
Instance 1
5 Iris-setosa Iris-setosa
Instance 2
5 Iris-setosa Iris-setosa
Instance 3
5 Iris-setosa Iris-setosa
Instance 4
5 Iris-setosa Iris-setosa
Instance 5
5 Iris-setosa Iris-setosa
Instance 6
5 Iris-setosa Iris-setosa
Instance 7
5 Iris-setosa Iris-setosa
Instance 8
5 Iris-setosa Iris-setosa
Instance 9
5 Iris-setosa Iris-setosa
Instance 10
5 Iris-setosa Iris-setosa
Instance 11
4 Iris-versicolor Iris-versicolor
Instance 12
5 Iris-versicolor Iris-versicolor
Instance 13
5 Iris-versicolor Iris-versicolor
Instance 14
5 Iris-versicolor Iris-versicolor
Instance 15
5 Iris-versicolor Iris-versicolor
Instance 16
5 Iris-versicolor Iris-versicolor
Instance 17
5 Iris-versicolor Iris-versicolor
Instance 18
5 Iris-versicolor Iris-versicolor
Instance 19
5 Iris-versicolor Iris-versicolor
Instance 20
5 Iris-versicolor Iris-versicolor
Instance 21
5 Iris-virginica Iris-virginica
Instance 22
5 Iris-virginica Iris-virginica
Instance 23
5 Iris-virginica Iris-virginica
Instance 24
4 Iris-versicolor Iris-virginica
Instance 25
5 Iris-virginica Iris-virginica
Instance 26
3 Iris-virginica Iris-virginica
Instance 27
4 Iris-versicolor Iris-virginica
Instance 28
5 Iris-virginica Iris-virginica
Instance 29
5 Iris-virginica Iris-virginica
Instance 30
4 Iris-virginica Iris-virginica
~~~~~

There you go....

Ok, I kind of lost interest in documenting this and making it better.
It's a proof-of-concept, after all. And it seems to work -- and it could be
implemented in a single line of APL, probably.
