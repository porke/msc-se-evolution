module UnitComplexity

import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import Common;

int computeCyclomaticComplexity(loc method) {
	str methodContent = readFile(method);
	return 0;
}

void main() {
	loc project = |project://smallsql0.21/|;
	M3 projectModel = createM3FromEclipseProject(project);
	set[Declaration] asts = createAstsFromDirectory(project + "src", true);
	iprintln(asts);
	
	list[loc] methodList = toList(methods(projectModel));	

	println("Cyclomatic complexity: <computeCyclomaticComplexity(methodList[0])>");
	println("Method count: <size(methodList)>");	
}

CodeProperty computeUnitComplexity(loc project) {
	return <"UnitComplexity", []>;
}
