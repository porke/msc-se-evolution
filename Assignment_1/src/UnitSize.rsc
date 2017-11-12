module UnitSize

import Common;
import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;

void main() {
	int unitSize = 0;
	int numberOfMethods = 0;

	loc project0 = |project://smallsql0.21_src/|;
	M3 projectModel0 = createM3FromEclipseProject(project0);
		
	//Units are methods in java. The next line extracts all methods from the project.
	unitMethods = methods(projectModel0);
	
	//Calculate the number of methods in the program
	sizeMethods = size(unitMethods);
	
	//Add all method locations in a list
	list[loc] methodList = toList(unitMethods);
	
	//In a loop, calculate LOC for each method, and add in total
	for (int n <- [0..sizeMethods]){
	numberOfMethods += 1; //Used as a test to see if it matches the size found previously
	//list[loc,int] unitSize += computeMethodSize(methodList[n]); function that finds LOC of method. 
	}
	
	
	if(numberOfMethods == sizeMethods)
	println(numberOfMethods);
	else
	println("Something went wrong! sizeMethods = <sizeMethods> while numberOfMethods = <numberOfMethods>");
}

//
int computeMethodSize(loc methodLoc){
	//make a list of (method loc, LOC of method) for all methods;
}

CodeProperty computeUnitSize(loc project) {
	return <"UnitSize", []>;
}
