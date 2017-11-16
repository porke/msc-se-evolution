module Volume

import IO;
import List;
import util::Math;

import Common;

int getStatementsPerFunctionPointForJava() {
	// Taken from Programming Languages Table
	return 53;
}

int computeTheNumberOfFunctionPoints(int totalLoC) {
	return totalLoC / getStatementsPerFunctionPointForJava();
}

int getProductivityAveragePerStaffYearForJava() {
	// LANGUAGE LEVEL   PRODUCTIVITY AVERAGE PER STAFF MONTH
	//  4 - 8           10 to 20 Function Points
	// Java is level 6, therefore we can take 15 function points per staff month
	return 15 * 12; 
}

real computeManYears(int totalLinesOfCode) {
	return toReal(computeTheNumberOfFunctionPoints(totalLinesOfCode)) / getProductivityAveragePerStaffYearForJava();
}

list[loc] getSourceFilesFromDirRecursively(loc directory) {
	list[loc] sourceFiles = [directory + s | s <- listEntries(directory), isFile(directory + s)];
	list[loc] subDirectories = [directory + s | s <- listEntries(directory), isDirectory(directory + s)];	
	return sourceFiles + [*getSourceFilesFromDirRecursively(d) | d <- subDirectories];
}

int computeTotalLinesOfCode(loc projectLocation) {
	list[int] linesPerFile = [getLinesOfCodeFromLocation(s) | s <- getSourceFilesFromDirRecursively(projectLocation)];		
	return sum(linesPerFile);
}

CodeProperty computeVolume(loc project) {	
	int totalLinesOfCode = computeTotalLinesOfCode(|project://smallsql0.21/src/smallsql/|);
	real totalManYears = round(computeManYears(totalLinesOfCode), 0.01);		
	return <"Volume", [<"LOC", totalLinesOfCode>, <"ManYears", totalManYears>]>;
}

void main() {
	loc project0 = |project://smallsql0.21/|;
	iprintln(computeVolume(project0));
}
