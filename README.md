# Software Exolution - Assignment 1

**Authors**
 - Wojciech Czabanski
 - George Vletsas

## General Approach

The general approach is aligned with the EASY paradigm. This means that the modules in the project directly translate to phases in the paradigm.

### E - Extract

The **Volume**, **UnitComplexity**, **UnitSize** and **Duplication** modules extract the code properties in the form of metrics (string, int tuples). This is orchestrated by the **MaintainabilityModel** module.

### A - Analyse

The **MaintainibilityModel** module receives the metrics from the modules computing the specific code properties. It applies the SIG Maintainability Model to the code properties obtained and maps them to system properties according to the ISO guidelines.

## SY - Synthesize

The **MaintainabilityModelRenderer** module receives the computed system properties and the accompanying code properties from the **MaintainabilityModel** and uses them to draw a visualization of the SIG maintainability model. The SIG maintainability model is illustrated as a tree where the root is the overall maintainability score, the first level of depth are the SIG model system property scores and the second, lowest level of depth breaks down the system property scores into code property scores. For convenience the branches and leaves are also colored according to quality: red corresponds to very low quality, dark green to very high quality.

## Specific approach

## Volume

### Metric computation

The volume is computed by loading all the lines in the files in the project source subfolder and filtering the following lines:
- Consisting only whitespace
- Consisting a single line comment preceeded by whitespace: `[whitespace]//`
- Constiting a single line comment written using a multi line syntax, preceeded by whitespace: `[whitespace]/* comment */`
- Multi line comments: `/*...*/`

Using the obtained line counts, the property also provides a man years metric, using the Programming Languages Table. According to it, Java is a language of level 6 and the number of statements in Java per function point is equal to 53. We assume that one line corresponds to one statement. Languages between the levels of 4 and 8 correspond to 10-20 function points per developer per month. Using this 

### Quality computation

The quality is computed by comparing the number of lines ofto obtain a rank by using the SIG maintainability model threshold table.

## Unit size

### Metric computation

The unit size is obtained by first computing the M3 model from the Eclipse projects, then extracting all the methods, and then obtaining the line count for each of the methods. The same line filters are used as for the volume metric.

### Quality computation

The unit size quality is computed by aggregating the unit sizes per rank using the Better Code Hub guidelines and these are as follows:
 - 15 lines of code or less - low risk code,
 - 15-30 lines of code - medium risk code,
 - 30-60 lines of code - high risk code,
 - 60 lines of code or more - very high risk code

After the aggregation is done, the percentage of code falling into each of the categories is computed and the quality is derived using the same table as for unit complexity.

## Unit complexity

### Metric computation

The metric is computed by loading the abstract syntax trees for each file and then extracting the method abstract syntax trees for each method.

For each method, the final cyclomatic complexity value is computed by including the number of:
 - if statements
 - else statements
 - for statements,
 - while statements, 
 - do..while statements,
 - case labels in switch statements,
 - expressions containing the "&&" operator.

This is done as per suggestions in: NIST Special Publication 500-235 Structured Testing: A Testing Methodology Using the Cyclomatic Complexity Metric, T. McCabe, A. Watson, September 1996, [Ch 4, Simplified Complexity Calculation]

### Quality computation

The quality for unit complexity is computed in a similar manner as for the unit size. However, we decided to compare the final complexity percentages to total code complexity, as opposed to the paper which suggests comparing numbers of lines in the complex function to the total number of lines. We argue that since total complexity is correlated to total volume, the results will not diverge.

## Duplication

### Metric computation

The duplication is calculated as a case by case comparison. Initially, the method bodies are grabbed from UnitSize, excluding the 1st and last line. Then we use two for loops with i and j to check each method, while also ignoring methods smaller than 6 lines. The rest of the algorithm can be described in steps:
1. If we are searching through the same method body, line2 starts from the 6th line to ensure it doesn't match itself
   Also, in this case if the method is smaller than 12 lines we skip this iteration of j.
2. While line counter has not reached the final 5 lines, check for: 
   if method1[line] and method1[line+5] is an element of method2, and all elements inbetween are a subset of method 2
3. Find the line in method 2 where method1[line] == method2[line2], and method1[line+5] == method2[line2+5].
4. If the 6 lines we found match in strict sequence (using slices), start looking at their successors until they stop matching.
5. Add lines to result. 
6. Reset line counters and goto step 1

If i==j there are special conditions to ensure that we do not get incorrect result. Step 1 is one of these conditions, and
we also have a similar one for the final 6 lines of code to ensure that line1==line2 when i==j never happens.

###Design Questions and Changes

We found it interesting that the SIG model did not consider other types of clones, and we also were wondering why was the specific
number of 6 lines chosen?

Initially, the design used Maps. The main map had the lines of code of the method on one side, and the other side contained tuples of all method locations that matched those LOC. We were to use this to compute all methods larger than 6 lines, and then go into case by case comparison, however we decided it was the same with lists of the method bodies, and required less LOC.


### Quality computation

The quality is computed by comparing the number of duplicated lines to the total line count and obtaining a rank by using the SIG maintainability model threshold table.


## Additional Metrics

###Coupling
It was a surprise that coupling was not included in the SIG model. One could argue that it is one of the most important metrics to look at in terms of software maintainability. If the code contains a high amount of strong coupling, this is negative for its maintainability as one small change in a module may create a ripple effect of changes. The impact of change may discourage further evolution of the project, and poses quite a danger to code-breaking bugs.
The only reason it could have been excluded is that it is very difficult to fully automate, but similar to duplication, a simpler version of coupling could be used as a metric.
