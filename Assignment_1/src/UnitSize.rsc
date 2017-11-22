module UnitSize

import Common;
import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;

list[loc] getMethodList(loc project) {
	projectModel0 = createM3FromEclipseProject(project);
	unitMethods = methods(projectModel0);
	list[loc] methodList = toList(unitMethods);
	
	return methodList;
}


CodeProperty computeUnitSize(loc project) {
	methodList = getMethodList(project);
	//sizes(str location, int LOC of method)
	list[Metric] sizes = [<method.uri,size(pruneMultilineComments(pruneWhitespaceAndSingleLineComments(readFileLines(method))))> | method <- methodList];
	return <"UnitSize",sizes>;
}
