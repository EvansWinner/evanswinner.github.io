# TODOSTACK.EL

[Originally published on evanswinner.com, 2011-05-14 Sat]

Of all forms of time-wasting, writing time-management
software is most sublime.

For at least a certain segment of the population, location
is becoming less and less important. Once, we went out to
rent a movie at the local Plex, drove to the grocery store
for food, left the house for entertainment and of course, to
work. Now we watch movies streaming on Netflix, order
groceries (or pizza) to be delivered from an online service,
and of course, more and more, we telecommute. As the first
three dimensions of place thus recede in importance to our
existence we become freer and freer to focus our attention
on that most fundamental of our lives' parameters, the
fourth: time.

Philosophizing aside, my own tiny contribution, posted at
EmacsWiki Github, is todostack.el. It is a set of
interactive functions in Emacs Lisp which allow you to keep
a simple to-do list as a stack. The idea was inspired by a
blog post by one Shrutarshi Basu1 in which is discussed the
idea of using a priority queue for a to-do list. This seems
like a good or at least interesting idea. Thinking about
myself, it occurred to me that my problem is that, easily
distractible as I am, I need a way to keep track of what I
am supposed to be doing, that will feed me one and only one
item at a time in the order that they have been made the
current highest priority. I am a system administrator and
this may appeal more to people with that sort of job than to
those with ... other sorts of jobs. In my work it seems that
whatever is most recent is most important, so this seems to
be useful to me thus far. When I finish a task I don't have
to sit around wondering what it was I was supposed to do
next, or that had been interrupted. I simply pop the stack
and see what's next. I still use Org-mode and the Org Agenda
for my longer-term projects and to-do lists, but for a time
scale from about one evening to a week or so, todostack.el
seems useful so far. The thing is experimental, so use at
your own risk, and so forth; read the commentary in the
headers. There is some Org-mode integration, actually: you
can output a buffer full of your stack as an Org-mode TODO
list, and you can also snarf up such a buffer into your
stack, so... that's nice, I guess. Anyway, it's only lightly
tested, and of course only for my uses on my systems, so it
no doubt has some bugs. It's also got a really odd
doc-string hack which seemed like a good idea at the time,
but sort of ballooned out a bit out of control. At any rate,
for what it is worth, as they say.

Footnotes:
http://bytebaker.com/2009/12/02/im-leaving-google-tasks/

     Evans Winner
     Albuquerque, New Mexico
     May, 2011

