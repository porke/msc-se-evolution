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
	int line2 = 0;
	int beggining;
	list[int] result = [];
	


	for ( int i <- [0..size(methodBody)-2], size(methodBody[i].body)>5 ){
		
		for (int j <- [(i+1)..size(methodBody)], size(methodBody[j].body)>5){
				
				//while line counter is smaller than the method size-6, check for:
				//if method1[line] and method1[line+5] is an element of method2, and all elements inbetween are a subset of method 2
				while (line < size(methodBody[i].body)-6) {
					if (methodBody[i].body[line] in methodBody[j].body && methodBody[i].body[line+5] in methodBody[j].body && (methodBody[i].body[line..line+6] < methodBody[j].body)){
						
						//Find the line in method 2 where method1[line] matches, and method1[line+5] also matches (with method2[line2+5]).
						while (methodBody[i].body[line] != methodBody[j].body[line2] && methodBody[i].body[line+5] != methodBody[j].body[line2+5] && line2 < size(methodBody[j].body)-6){ line2 += 1;} //what if you find a similar line
						
						//if the 6 lines we found match in strict sequence, start looking at their successors until we don't get a match, meaning duplicated lines ended.
						if (methodBody[i].body[line..line+6] == methodBody[j].body[line2..line2+6]){

							beggining = line;
							line +=		5;
							line2 +=	5;
							
							while (methodBody[i].body[line] == methodBody[j].body[line2] && line < size(methodBody[i].body)-1 && line2 < size(methodBody[j].body)-1 ){
								line +=		1;
								line2 +=	1;
							}
							
							//final check to see if everything inbetween our first line and final line exist in method 2. If they do, add lines to result.
							if (methodBody[i].body[beggining..line] < methodBody[j].body){
								result += ((line+1)-beggining);
								println("<result>, Method:<i> with <j>, Lines: <beggining> to <line> ");
							}
						} else {line += 1; line2 = 0;} //end of line 44 if. If no match is found we restart the search from the next line.
					
						
					} else {line += 1;} //end of line 38 if
				 
				 } //while end
			 line = 	0;
			 line2 = 	0;	 

		} //for j end
	} //for i end
	
	return result;
	
}



CodeProperty computeDuplication(loc project) {

	list[int] duplicationTable = duplicationCheck(project);
	int duplicatedLines = sum(duplicationTable);
	return <"Duplication", [<"ClonedLines", duplicatedLines>]>;
}
