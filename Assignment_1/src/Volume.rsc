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

CodeProperty computeVolume(loc project) {	
	int totalLinesOfCode = computeTotalLinesOfCode(project);
	real totalManYears = round(computeManYears(totalLinesOfCode), 0.01);		
	return <"Volume", [<"LOC", totalLinesOfCode>, <"ManYears", totalManYears>]>;
}

