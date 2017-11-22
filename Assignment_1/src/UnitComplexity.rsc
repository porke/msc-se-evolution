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
	//if (method !:= |java+method:///smallsql/database/Command/verifyParams()|) {
	//	return 0;
	//}
	
	int complexity = 0;
	str className = method.parent.file;	
	// Extract the method name from the uri
	if (/^<methodName:.*>(\(.*\))$/ := method.file) {
		visit(fileAst) {
			// Find the class and the method in the file
			case compilationUnit(_, [*_, class(className, _, _, [*_, method(_, methodName, _, _, methodBody), *_]), *_]): {
				list[loc] fors = [f.src | /Statement f:\for(_,_,_,_) := methodBody];
				list[loc] whiles = [f.src | /Statement f:\while(_,_) := methodBody];
				list[loc] dos = [f.src | /Statement f:\do(_,_) := methodBody];
				list[loc] ifs = [f.src | /Statement f:\if(_,_) := methodBody];
				list[loc] ifElses = [f.src | /Statement f:\if(_,_,_) := methodBody];
				list[loc] cases = [f.src | /Statement f:\case(_) := methodBody];				
				return 1 + size(fors) + size(ifs) + size(cases) + size(whiles) + size(dos) + 2 * size(ifElses);	
			}
		}
	}
	
	return complexity;
}

CodeProperty computeUnitComplexity(loc project) {
	M3 projectModel = createM3FromEclipseProject(project);	
	list[loc] classList = toList(classes(projectModel));
	list[ClassAst] astsPerClass = [<c, toList(methods(projectModel, c)), createAstFromFile(c, true)> | c <- classList];

	return <"UnitComplexity", <"LOC", computeTotalLinesOfCode(project)> + [*[<m.uri, computeCyclomaticComplexity(m, c.ast)> | m <- c.methods] | c <- astsPerClass]>;
}

void main() {
	loc project = |project://smallsql0.21/src|;
	M3 projectModel = createM3FromEclipseProject(project);	
	
	list[loc] classList = toList(classes(projectModel));
	list[ClassAst] astsPerClass = [<c, toList(methods(projectModel, c)), createAstFromFile(c, true)> | c <- classList];
	list[MethodComplexity] complexities = [*[<m, computeCyclomaticComplexity(m, c.ast)> | m <- c.methods] | c <- astsPerClass];
	text(complexities);
}
