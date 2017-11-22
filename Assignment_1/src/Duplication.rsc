module Duplication

import Common;
import IO;
import Set;
import List;
import Map;

import Volume;
import UnitSize;
import DateTime;

list[tuple[list[str] body, loc name]] methodBodies(loc project){
	//|project://smallsql0.21/src/smallsql|
	methodList = getMethodList(project);
	list[tuple[list[str] body, loc name]] methodBody = [<pruneMultilineComments(pruneWhitespaceAndSingleLineComments(readFileLines(location)))[1..size(readFileLines(location))-1],location> | location <- methodList ];
	
	return methodBody;
}


//[i | i <- [0..size(x[237].body)-5], j <- [0..size(x[800].body)-5], x[327].body[i..i+5] == x[800].body[j..j+5] ]; 
list[int] duplicationCheck(loc project){

	methodBody = methodBodies(project);
	int line = 0;
	int line2 = 0;
	int beggining = 0;
	int beggining2 = 0;
	list[int] result = [];
	


for ( int i <- [0..size(methodBody)-1], size(methodBody[i].body)>5 ){
		
	for (int j <- [i..size(methodBody)], size(methodBody[j].body)>5){ 	
		
				//if we are searching through the same method body, line2 starts from the 6th line to ensure it doesn't match itself
				//also, in this case if the method is smaller than 12 lines we skip this iteration of j.
				if (i == j && size(methodBody[j].body) > 11){line2 = line + 5; beggining2 = line2;}
				else if(i==j && size(methodBody[j].body) < 12){continue;}
				
				
				//while line counter is smaller than the method size-6, check for:
				//if method1[line] and method1[line+5] is an element of method2, and all elements inbetween are a subset of method 2
				while (line < size(methodBody[i].body)-6 && line2 < size(methodBody[j].body)-6) {
					if (methodBody[i].body[line] in methodBody[j].body && methodBody[i].body[line+5] in methodBody[j].body && (methodBody[i].body[line..line+6] < methodBody[j].body)){
						
						//Find the line in method 2 where method1[line] matches, and method1[line+5] also matches (with method2[line2+5]).
						while (methodBody[i].body[line..line+6] != methodBody[j].body[line2..line2+6] && line2 < size(methodBody[j].body)-6){ line2 += 1;}
						
						//if the 6 lines we found match in strict sequence, start looking at their successors until we don't get a match, meaning duplicated lines ended.
						if (methodBody[i].body[line..line+6] == methodBody[j].body[line2..line2+6]){

							beggining = line;
							line +=		6;
							line2 +=	6;
							while (line2 < size(methodBody[j].body)-1 && methodBody[i].body[line] == methodBody[j].body[line2] && line < size(methodBody[i].body)-1  ){
								line +=		1;
								line2 +=	1;
							}

							//final check to see if everything inbetween our first line and final line exist in method 2. If they do, add lines to result.
							if (methodBody[i].body[beggining..line] < methodBody[j].body){
								if ((i==j && line2 != line) || i != j ){
									result += ((line)-beggining);
									println("<methodBody[i].body[beggining..line] == methodBody[j].body[((line2)-(line-beggining))..line2]>, Method:<i> with <j>, Lines: <beggining> to <line> with <((line2)-(line-beggining))> to <line2> ");
								}
							}
							if(i==j && line+6 < size(methodBody[j].body)-5){ beggining2 = line+6; line2 = beggining2; }
							
						} else {
							line += 1; 
							if(i==j && line+6 < size(methodBody[j].body)-5){ beggining2 += 1; line2 = beggining2;}else{line2 = beggining2;}
						} //end of line 44 if. If no match is found we restart the search from the next line.
					
						
					} else {line += 1;} //end of line 38 if
				 
				 } //while end
			 line = 		0;
			 line2 = 		0;
			 beggining2=	0;	 

		} //for j end
	} //for i end
	
	return result;
	
}



CodeProperty computeDuplication(loc project) {
	datetime stopwatch = now();
	list[int] duplicationTable = duplicationCheck(project);
	int duplicatedLines = sum(duplicationTable);
	println("Unit size computed in: <createDuration(stopwatch, now())>");
	return <"Duplication", [<"ClonedLines", duplicatedLines>]>;
}
