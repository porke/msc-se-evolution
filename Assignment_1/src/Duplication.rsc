module Duplication

import Common;
import IO;
import Set;
import List;
import Map;

import Volume;
import UnitSize;


list[tuple[list[str] body, loc name]] methodBodies(loc project){
	//|project://smallsql0.21/src/smallsql|
	methodList = getMethodList(project);
	list[tuple[list[str] body, loc name]] methodBody = [<pruneMultilineComments(pruneWhitespaceAndSingleLineComments(readFileLines(location)))[1..size(readFileLines(location))-1],location> | location <- methodList ];
	
	return methodBody;
}

list[int] duplicationCheck(loc project){

	methodBody = methodBodies(project);
	int line = 0;
	int beggining;
	list[int] result = [];
	
	/*	int i = 1588;
		int j = 2179;  for testing */
	//strict subset does not only keep the values that are strictly succeeding each other. FIX!! 
	
	for ( int i <- [0..size(methodBody)-2] ){
		for (int j <- [(i+1)..size(methodBody)]){
			if(size(methodBody[i].body)>5 && size(methodBody[j].body)>5){
				
				while (line < size(methodBody[i].body)-6) {
					if (methodBody[i].body[line] in methodBody[j].body && methodBody[i].body[line+5] in methodBody[j].body && (methodBody[i].body[line..line+6] < methodBody[j].body)){
						
						beggining = line;
						line += 5;
						while (methodBody[i].body[line] in methodBody[j].body && line < size(methodBody[i].body)-1 ){
							line += 1;
						}
						if (methodBody[i].body[beggining..line] < methodBody[j].body){
							result += (line-beggining);
							println("<result>, Method:<i> with <j>");
						}
						
					} else {line += 1;} 
				 
				 } //while end
			 line = 0;	 
			 }//if sizecheck end
		} //for j end
	} //for i end
	
	return result;
	
}



CodeProperty computeDuplication(loc project) {
	int totalLinesOfCode = computeTotalLinesOfCode(project);
	list[int] duplicationTable = duplicationCheck(project);
	int duplicatedLines = sum(duplicationTable);
	println("Duplicated Lines: <duplicatedLines>, Project total LOC: <totalLinesOfCode>");
	return <"Duplication", [<"ClonedLines", (duplicatedLines/(totalLinesOfCode*1.0))*100>]>;
}
