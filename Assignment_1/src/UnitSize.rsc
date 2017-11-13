module UnitSize

import Common;
import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;

list[loc] getMethodList(loc project) {
	//change to project input
	loc project0 = |project://smallsql0.21/|;
	projectModel0 = createM3FromEclipseProject(project0);
		
	//Units are methods in java. The next line extracts all methods from the project.
	unitMethods = methods(projectModel0);
	
	//Calculate the number of methods in the program
	sizeMethods = size(unitMethods);
	
	//Add all method locations in a list
	list[loc] methodList = toList(unitMethods);
	
	return methodList;
}


CodeProperty computeUnitSize(loc project) {
	methodList = getMethodList(project);
	//sizes(str location, int LOC of method)
	list[Metric] sizes = [<method.uri,size(readFileLines(method))> | method <- methodList];
	return <"Unit Size",sizes>;
}
