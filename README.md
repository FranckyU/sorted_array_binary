sorted_array_binary
===================

[![Build Status](https://travis-ci.org/ledestin/sorted_array_binary.png)](https://travis-ci.org/ledestin/sorted_array_binary)
[![Coverage Status] (https://coveralls.io/repos/ledestin/sorted_array_binary/badge.png)] (https://coveralls.io/r/ledestin/sorted_array_binary)
[![Code Climate](https://codeclimate.com/github/ledestin/sorted_array_binary.png)](https://codeclimate.com/github/ledestin/sorted_array_binary)

A sorted array using binary search

## Why

1. Neither of the existing sorted arrays gems use binary search (i.e. slow or
   very slow).
2. I don't like their source code, so I decided to roll my own, instead of
   contributing.

Existing sorted array gems as of Jan 2014:
* sorted_array (0.0.5)
* array-sorted (1.1.2)

## Example

```ruby
require 'sorted_array_binary'

# Use standard sorting via <=>.
array = SortedArrayBinary.new
array.push 'b', 'a' #=> ['a', 'b']

# Use custom sorting block.
array = SortedArrayBinary.new { |a, b| b <=> a }
array.push 'a', 'b' #=> ['b', 'a']

# Nils not allowed.
array.push nil #=> ArgumentError is raised
```

## Performance

When #push'ing 1000 random numbers into an array:
```
sorted_array (0.0.5)		1.179088
array-sorted (1.1.2)		0.076348
sorted_array_binary (0.0.1)     0.015969
```
