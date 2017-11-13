module UnitComplexity

import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import Common;

alias ClassAst = tuple[loc className, list[loc] methods, Declaration ast];
alias MethodComplexity = tuple[loc method, int complexity];

int computeCyclomaticComplexity(loc method, Declaration classAst) {	
	if (method := |java+method:///smallsql/database/Command/verifyParams()|)
	{
		// classes from the compilation unit: compulationUnit([], classes, []);
		// match the appropriate class from the list in the compilation unit, class(name, _, _, _, ...) 
		// match a method on the method name and do something with it
		str className = method.parent.file;
		visit(classAst) {
			case compilationUnit(_, [*_, class(className, _, _, classBody), *_]): {				
				if (/^<methodName:.*>(\(.*\))$/ := method.file) {
					if ([*_, method(_, methodName, _, _, methodImplementation), *_] := classBody) {
						iprintln(methodImplementation);
						return 111;
					}
				}
			}
		}
		return 666;
	}
	else return 0;
}

void main() {
	loc project = |project://smallsql0.21/|;
	M3 projectModel = createM3FromEclipseProject(project);	
	
	// FIXME: I only test the first class
	list[loc] classList = [toList(classes(projectModel))[0]];
	list[ClassAst] astsPerClass = [<c, toList(methods(projectModel, c)), createAstFromFile(c, true)> | c <- classList];
	list[MethodComplexity] complexities = [*[<m, computeCyclomaticComplexity(m, c.ast)> | m <- c.methods] | c <- astsPerClass];
	iprintln(complexities);
	// TODO: work further with the complexities
}

CodeProperty computeUnitComplexity(loc project) {
	return <"UnitComplexity", []>;
}
