module UnitComplexity

import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import Common;

alias ClassAst = tuple[loc className, list[loc] methods, Declaration ast];
alias MethodComplexity = tuple[loc method, int complexity];

int computeCyclomaticComplexity(loc method, Declaration ast) {
	// TODO: Compute the complexity based on the method location and the ast
	return 0;
}

void main() {
	loc project = |project://smallsql0.21/|;
	M3 projectModel = createM3FromEclipseProject(project);	
	list[loc] classList = toList(classes(projectModel));	
	list[ClassAst] astsPerClass = [<c, toList(methods(projectModel, c)), createAstFromFile(c, true)> | c <- classList];	
	list[MethodComplexity] complexities = [*[<m, computeCyclomaticComplexity(m, c.ast)> | m <- c.methods] | c <- astsPerClass];
	iprintln(complexities);
	// TODO: work further with the complexities
}

CodeProperty computeUnitComplexity(loc project) {
	return <"UnitComplexity", []>;
}
