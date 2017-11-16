module UnitComplexity

import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::ValueUI;

import Common;

alias ClassAst = tuple[loc className, list[loc] methods, Declaration ast];
alias MethodComplexity = tuple[loc method, int complexity];

int computeCyclomaticComplexity(loc method, Declaration fileAst) {
	if (method !:= |java+method:///smallsql/database/Command/verifyParams()|) {
		return 0;
	}
	
	int complexity = 0;
	str className = method.parent.file;
	
	// Extract the method name from the uri
	if (/^<methodName:.*>(\(.*\))$/ := method.file) {
		visit(fileAst) {
			// Find the class and the method in the file
			case compilationUnit(_, [*_, class(className, _, _, [*_, method(_, methodName, _, _, methodBody), *_]), *_]): {
				fors = [f.src | /Statement f:\for(_,_,_,_) := methodBody];
				ifs = [f.src | /Statement f:\if(_,_) := methodBody];
				iprintln(fors+ifs);
				return 123;	
			}
		}
	}
	
	return complexity;
}

void main() {
	loc project = |project://smallsql0.21/|;
	M3 projectModel = createM3FromEclipseProject(project);	
	
	list[loc] classList = [toList(classes(projectModel))[0]];
	list[ClassAst] astsPerClass = [<c, toList(methods(projectModel, c)), createAstFromFile(c, true)> | c <- classList];
	list[MethodComplexity] complexities = [*[<m, computeCyclomaticComplexity(m, c.ast)> | m <- c.methods] | c <- astsPerClass];
}

CodeProperty computeUnitComplexity(loc project) {
	M3 projectModel = createM3FromEclipseProject(project);	
	list[loc] classList = toList(classes(projectModel));
	list[ClassAst] astsPerClass = [<c, toList(methods(projectModel, c)), createAstFromFile(c, true)> | c <- classList];

	return <"UnitComplexity", [*[<m.uri, computeCyclomaticComplexity(m, c.ast)> | m <- c.methods] | c <- astsPerClass]>;
}
