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

TODO: George to describe how he is doing it
TODO: Include the questions from the document in the report

### Quality computation

The quality is computed by comparing the number of duplicated lines to the total line count and obtaining a rank by using the SIG maintainability model threshold table.
