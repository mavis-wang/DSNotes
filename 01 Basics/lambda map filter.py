# Lecture 4

# Lambdas
# d = {1:"San Francisco", 2:"New York", 3:"Chicago", 4:"Los Angeles"}
#
# # sort by dictionary keys
# print(sorted(d.items()))
#
# # sort by dictionary values
# print(sorted(d.items(), key=lambda x: x[1]))

# Map
# map(function, iterable)  map object (an iterable)

# # example 1
# cities = ["San Jose", "Redwood City", "Sunnyvale"]
#
# # list comprehensions
# [len(s) for s in cities]
# itr = map(len, cities)
# print(itr)
# print(next(itr))
# print(next(itr))

#  # example 2
#  # list of numbers
# numbers = [1, 2, 3, 4, 5, 6]
# def double(num):
#     return num*2
#
# # list comprehensions
# [double(n) for n in numbers]
#
# # map examples
# print(map(double, numbers))


# # Filter
# # filter(predicate, iterable)  filter object (an iterable)
#
#  # list of numbers
# numbers = [1, 2, 3, 4, 5, 6]
# def less_than_4(num):
#     return num < 4
#
# # list comprehensions
# [n for n in numbers if less_than_4(n)]
#
#  # list of numbers
# numbers = [1, 2, 3, 4, 5, 6] def less_than_4(num):
#     return num < 4
# # list comprehensions
# [n for n in numbers if less_than_4(n)]
# # filter examples
# filter(less_than_4, numbers)

l1 = [1,2,3,4,5,6]
m1 = map(lambda x: x*2, l1)
f1 = filter(lambda x: x > 10, m1)

print(m1)
print(f1)
print(next(m1))
print(next(f1))

