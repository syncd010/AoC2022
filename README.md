# Advent of Code 2022 in Dart

My solutions for the [Advent of Code 2022](https://adventofcode.com/2022) in [Dart](https://dart.dev/).

Going back to dart brings down the challenge, as it is a known, straightforward, not very exotic language but i don't have much time this year to learn (and fight with) a new language.

 As usual, there's very little or no error handling so the solutions blow up if the input files aren't exactly as expected and specified in each day's puzzle description.

Code is in the `bin` directory, input files are in the `data` directory.

## Post event impressions
I'm not quite sure why but this year wasn't as enjoyable as previous ones. I felt that the problems were either too simple or too a time consuming, without requiring smart insights to solve. The exceptions were day 21, which was quite enjoyable and day 22, which despite being hard was also satisfying.

Regarding Dart, it's a competent language, and that's saying much. It has a lot of modern mechanisms (extension functions for instance) but at the same time if feels clunkier than something like Kotlin (probably because of its syntactic  heritage). I sometimes felt that the solutions weren't as elegantly expressed as they could be because small syntactic things were missing. This is a compliment to Kotlin, but it's not necessarily a complaint about Dart, as one needs to consider its heritage: being a language whose initial goal was to be a replacement for Javascript, it naturally has some constraints baked in. The simple fact that i'm complaining about its elegance while comparing it to a modern language like Kotlin (which is currently considered to be one of the best), is in itself a compliment, as it implies that Dart is able to keep up with it somewhat. It's just that it is not the best and i'm not sure about why someone should use it instead of Kotlin. Apart from Google using it as the base for Flutter and Fuschia that is...

## Usage
To run:
> dart run :day{$day} [-t] [FILE]

This will run the 2 parts of the specified `$day`, using `FILE` as input. If no file is specified `./data/input{$day}` is used as input. If no file is specified and `-t` is used, `./data/input{$day}Test` is used instead. 

---

## [Day 1](https://adventofcode.com/2022/day/1)
Warm up.

## [Day 2](https://adventofcode.com/2022/day/2)
Still warming up.

## [Day 3](https://adventofcode.com/2022/day/3)
Not much to say, except that i had forgotten about Dart's string representation (runes and codeunits) so it took some time getting up to speed.

## [Day 4](https://adventofcode.com/2022/day/4)
Easier than the previous ones, which is odd. Today is Sunday which is usually the day with the hardest puzzles so this was atypical.

## [Day 5](https://adventofcode.com/2022/day/5)
This one took a bit more work, but it still was fairly straightforward.

## [Day 6](https://adventofcode.com/2022/day/6)
Yet another simple day. The solution is in an imperative style, as it was more adequate to the problem.

## [Day 7](https://adventofcode.com/2022/day/7)
It's starting to warm up. The only thing of note in the solution is the data structure representing the files and folders: I used a quick and dirty way to represent the files - a simple map with the complete file name (including the folder) as the key, and its size as the value -, and recovered the folder structure from that map by splitting the keys on the various '/'.

## [Day 8](https://adventofcode.com/2022/day/8)
Although the solution seems quite simple it has some corner cases that merit attention: it's necessary to look in the 4 directions separately and in part 2 one needs to also count trees of height equal to the one being considered. Apart from that it's a matter of taking some care to not mess up the indices (which leads to somewhat messy code).

## [Day 9](https://adventofcode.com/2022/day/9)
After creating some suitable data structures to represent the problem (`Position` and `Move`), the simulation was easy enough to do. The main insight is that the amount to move the tail is simply the sign of the difference between its position and the head position. Part 2 was also straightforward, just needing to keep a list of more knots and make each one follow the previous one.

## [Day 10](https://adventofcode.com/2022/day/10)
This day was just messy. Had to twist the code to account for the different cycle times, which resulted in overly ugly code...

## [Day 11](https://adventofcode.com/2022/day/11)
This was more interesting. Part one is a straightforward, convoluted and dull implementation, which at first got reused for part two and gave wrong results on round 1000. I quickly realized that it was overflowing (which is silent in Dart), and looked at the input trying to find some clues for a shortcut. The squaring was the obvious problem and moving to `bigints` might not solve the issue, given that the numbers would quickly get out of hand, leading to very slow execution (or even memory exhaustion). I suspected that the calculated `worry level` had to be truncated by something, and, given that the following operations are to check the `worry level` modulus the various divisibility numbers in the input (which are all prime), restricting the level up to the product of those divisibility numbers might work - it's kind of a round-robin number that get's capped at the product of the divisibility tests primes.

## [Day 12](https://adventofcode.com/2022/day/12)
A simple breadth first search, in which i used a generic search, anticipating that it might be used in future days.

## [Day 13](https://adventofcode.com/2022/day/13)
This wasn't theoretically challenging, but it took some work, as it was easy to mess up the indices while processing the input.

## [Day 14](https://adventofcode.com/2022/day/14)
Following the description, this problem was very similar to one in AoC2018, so i reused a lot of that solution. First part is very similar, with the major challenge being, once again, getting the indexes right. I used the same approach for part 2, expanding the cave map to account for the maximum possible dimensions. In retrospect, part 2 could be more efficiently calculated by noting that the number of occupied positions on each line can be calculated based on the previous line, but simulating the whole process was feasible and simpler given the work was already done for part 1.

## [Day 15](https://adventofcode.com/2022/day/15)
Not much to say, for a given row and each beacon/sensor it calculates the coverage for that row and merges overlapping ranges at the end. From this streamlined coverage the result can be directly calculated. Part 2 could use some optimization as it takes some time (2s), but i couldn't find any obvious one at first sight, so it stays like that.

## [Day 16](https://adventofcode.com/2022/day/16)
This one was though, took lots of experimenting and a long time.
The first insight is to simplify the valve's connections, storing only connections to valves that have rate > 0, and calculating the steps needed to reach and open them. This is a calculation of the shortest path on a graph with weighted edges, and i'm sure there are more efficient algorithms to do this, but i did a simple breadth first search, which was manageable given that the graphs aren't very big.
For the main part i first tried a search on the possible paths space. Now, on the test input there are 5 relevant valves, so the space is at most 5! nodes, which is trivial. But for the main input, there are 15 valves and 15! is unmanageable. Fortunately, the time cutoff of 30 steps culls most of those states, making it manageable (about 120k if memory serves me). A simple BFS worked , though quite slowly on the main input. I tried implementing an A* search, but the scoring function i come up with wasn't very good and didn't improve much. Part one was done, but i sensed that i was in trouble for part 2.

Even tough part 2 decreases the time limit, by adding another search concurrently the state space is much bigger because each search individually hits that time limit much later, considering much more states. My search implementation, extended to do both at the same time wouldn't work.
I spent quite some time trying to come up with alternative angles but, given the possible cases that might arise in the graph, i couldn't find any magical strategy that would work. Maybe a simple gradient descent optimization would find the correct answer, but it would do so by chance, as i don't think the state space is regular. Only a brute force checking of all possible paths would work, so i went back to that option and tried to optimize it. Ditching the straightforward BFS and generating all possible paths in a lazy way improved runtime quite a lot (though conceptually it's still the same, searching on all possible spaces). For part 2 there was no breakthrough, so i resigned myself to the same brute-force approach with some optimizations. It considers all possible pairs of paths, check if they are disjoint (searches explored different paths) and keeps the best score of each pair. To optimize, consider the paths by descending order of their score, and break when reaching a path whose score is less than half the current best score, as at that point there's no way to beat the best score. This worked surprisingly well, though it's a bit unsatisfactory, given that it is essentially an optimized brute force approach.

## [Day 17](https://adventofcode.com/2022/day/17)
Considerably easier than yesterday. Fearing part 2, i choose to represent blocks and the well efficiently from the start, hence the using of integers as bit arrays. Moving left or right are bitwise shifts, checking if spaces are occupied are `and`'s, and placing blocks on the well are `or`'s, which simplifies and speeds up the code.
For part 2 it was obvious that it was necessary to detect some kind of loop, but getting the right strategy took some time. The idea is to send falling blocks until there's a repeat of the first one on the same step of the input. Repeat the previous process some times, until the loop stabilizes and then use the number of height added in a look to extrapolate to the full 1 trillion.

## [Day 18](https://adventofcode.com/2022/day/18)
Much easier. Part 1 is straightforward given that verifying if a position is adjacent to another is equivalent to checking if they have a Manhattan distance of 1. For part 2, the description dropped a clue regarding the "flooding", which was helpful as i believe i would spend much more time looking for a strategy without that clue. The idea is to fill a bounding box that surrounds the input shape, collect the positions that are in that bounding box and different from the input shape, giving the "contour" of the shape, from which the result is computed.

## [Day 19](https://adventofcode.com/2022/day/19)
There's an integer programming solution lurking somewhere but, if there is, it isn't obvious, so i resigned myself to using a brute-force search. Part one was solvable with a breadth first search, taking (enormous) care to prune redundant/sub-optimal states in an acceptable time. Even with these optimizations it didn't work for part 2, so a switch to an A* search was necessary. The cost+estimate function sums the number of geodes we have + the number we're certain to get + a best case estimate, considering we can build a geode robot every step until the end. After fighting with indexes and more, this gives the correct answer in a couple of seconds.

## [Day 20](https://adventofcode.com/2022/day/20)
Much easier than the previous ones, as long as one recognizes that we should mix the indexes of the original input, and not the input itself. Part 2 is similar, making sure that the rotations are always modulus the input length - 1.

## [Day 21](https://adventofcode.com/2022/day/21)
This was the most enjoyable problem so far, simple yet smart. First part is a straightforward arithmetic operations interpreter. For the second part it calculates derivatives of the 4 operators and defines new operations for the derivatives. To get the answer we need the difference between the desired final values, and divide that by the derivative in order to the relevant variable. A simple and original problem, the best one this year. Autodiff ftw.

## [Day 22](https://adventofcode.com/2022/day/22)
This one took a long time. Part one was fairly straightforward, and not very satisfying. Just a matter of parsing the input and following the instructions, wrapping around when reaching a border. Part two was much more challenging. At first i hardcoded the cube faces transitions based on the test input cube - it was messy but not especially challenging. Constructing a physical cube would have helped, but i was lazy and just visualized it. After getting it to work correctly on the test input it failed spectacularly on the real input, at which point i decided to take a look at it and discovered that the cube was unfolded differently... So i had the option to hard code the solution to the real input or devise a general solution, not reliant on a specific cube unfolding. The generic solution seemed more fun, so i went with it. This proved to be a time sink, and led me to question my judgement...

Anyway, the solution tries to fold the cube starting with the faces that are direct neighbors on the input, and iteratively identifying the "missing" faces. Each missing face is filled with the previous face (counterclockwise) neighbor that is in the same direction as the original missing face, if those 2 faces are already filled. This is conceptually like folding the cube along shared edges, making sure to take into account and keep track of the rotations that are being made. From this we get a structure with all the faces, the neighbors of each face in each of the four directions and the rotation that each neighbor needs to be traversed. Wrapping through the faces needs to be done carefully, taking into account the rotations, which side we are entering, and whether the position we're entering is inverted relative to the face's coordinates. It's messy and somewhat brittle, but it's generic and it works.

I believe that the folding method isn't totally universal, there are folds that won't lead to the solution being able to reconstruct the faces (like a horizontal fold of 4 faces, with the remaining 2 on top and bottom respectively of the first and last). This could be solved with trying to fill missing faces with other neighbors of the previous face, but i didn't bother with it. 
It took a long time, but it was satisfying in the end.

## [Day 23](https://adventofcode.com/2022/day/23)
I guess were winding down. This one was a cellular automata with not very friendly rules. No major insight, either in part one or two. The solution is probably over-engineered and not very efficient, but it's readable.

## [Day 24](https://adventofcode.com/2022/day/24)
Yet another search problem, this time one for which A* is the most appropriate. The major insight is to recognize that the board's evolution has no dependency on the player's position, it is only dependent on time, so the search state shouldn't store boards, only positions (and time).
I chose to represent the board with 4 different layers, one for each direction, to make the evolution more straightforward. 
With this setup, part 2 is fairly straightforward, though it needed some tweaks to make the initial solution sufficiently generic to allow different goal positions and directions.

## [Day 25](https://adventofcode.com/2022/day/25)
And we end with a nasty one, though i admire the creativity that's necessary to come up with such a contrived problem. Decoding from the snafu base to decimal is straightforward, but encoding to it is another matter. Noticing that a number with n digits in snafu encodes from -(5^n - 1)/2 to +(5^n - 1)/2 (while the same n-digits number in base 5 encodes from 0 to 5^n - 1) i come up with a solution that "shifts" the original val by (5^n - 1)/2 and then encodes it similarly to like it was in base 5, making sure to deduce 2 to get the snafu corresponding symbol. Messy, and i suspect there are simpler and more obvious ones but it's mine.