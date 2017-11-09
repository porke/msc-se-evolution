module Volume

import IO;
import List;
import util::Math;

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

list[str] pruneMultilineComments(list[str] lines) {
	return lines;	
	// TODO: Finish multiline comment pruning
	//return for (str line <- lines) {
	//	if (/^[\s]*[\/*]{1}.*$/ := line) multiLine += 1;
	//	else if (/^.*[*\/]{1}.*$/ := line) multiLine += 1;		
	//}
}

int getLinesOfCodeFromFile(loc file) {
	list[str] lines = [line | line <- readFileLines(file),
							/^[\s]*$/ !:= line,					// Whitespace lines
							/^[\s]*[\/]{2,}.*$/ !:= line ];		// Single line comments	
	return size(pruneMultilineComments(lines));
}

list[loc] getSourceFilesFromDirRecursively(loc directory) {	
	list[loc] sourceFiles = [directory + s | s <- listEntries(directory), isFile(directory + s)];
	list[loc] subDirectories = [directory + s | s <- listEntries(directory), isDirectory(directory + s)];
	return sourceFiles + [*getSourceFilesFromDirRecursively(d) | d <- subDirectories];
}

int computeTotalLinesOfCode(loc projectLocation) {
	list[int] linesPerFile = [getLinesOfCodeFromFile(s) | s <- getSourceFilesFromDirRecursively(projectLocation)];		
	return sum(linesPerFile);
}

void main() {
	println("LOC: <getLinesOfCodeFromFile(|project://smallsql0.21/src/smallsql/database/Column.java|)>");	
	//int totalLinesOfCode = computeTotalLinesOfCode(|project://smallsql0.21/src/smallsql/|);
	//println("LOC: <totalLinesOfCode>");
	//println("MY: <round(computeManYears(totalLinesOfCode), 0.01)>");
}


