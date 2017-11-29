module Type0_Duplication

import Common;

import IO;

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
	int beggining = 0;
	int beggining2 = 0;
	list[int] result = [];
	

for ( int i <- [0..size(methodBody)], size(methodBody[i].body)>5 ){
		
	for (int j <- [i..size(methodBody)], size(methodBody[j].body)>5){ 	
		
		tempSizeI = size(methodBody[i].body);
		tempSizeJ = size(methodBody[j].body);
		
				//if we are searching through the same method body, line2 starts from the 6th line to ensure it doesn't match itself
				//also, in this case if the method is smaller than 12 lines we skip this iteration of j.
				if (i == j && tempSizeJ > 11){line2 = line + 5; beggining2 = line2;}
				else if(i==j && tempSizeJ < 12){continue;}
				
				
				//while line counter has not reached the final 5 lines, check for:
				//if method1[line] and method1[line+5] is an element of method2, and all elements inbetween are a subset of method 2
				while (line < tempSizeI-5 && line2 < tempSizeJ-5) {
					if (methodBody[i].body[line] in methodBody[j].body && methodBody[i].body[line+5] in methodBody[j].body && (methodBody[i].body[line..line+6] < methodBody[j].body)){
						
						//Find the line in method 2 where method1[line] matches, and method1[line+5] also matches (with method2[line2+5]).
						while (methodBody[i].body[line..line+6] != methodBody[j].body[line2..line2+6] && line2 < tempSizeJ-6){ line2 += 1;}
						
						//if the 6 lines we found match in strict sequence, start looking at their successors until we don't get a match
						if (methodBody[i].body[line..line+6] == methodBody[j].body[line2..line2+6]){

							beggining = line;
							line +=		5;
							line2 +=	5;
							while (line2 < tempSizeJ-1 && line < tempSizeI-1 && methodBody[i].body[line+1] == methodBody[j].body[line2+1]   ){
								line +=		1;
								line2 +=	1;
							}

							
							//Add to result. Special condition for i==j because it counts the final 6 lines as the same.
							if ((i==j && line2 != line) || i != j ){
								result += ((line+1)-beggining);
								println("<methodBody[i].body[beggining..line+1] == methodBody[j].body[((line2)-(line-beggining))..line2+1]>, Method:<i> with <j>, Lines: <beggining> to <line+1> with <((line2)-(line-beggining))> to <line2+1> ");
							}
							
							//if i==j we use beggining2 = line+6 to make sure that line and line2 are not the same.
							if(i==j && line+6 < tempSizeJ-5){beggining2 = line+6; line2 = beggining2;}
							
						} else {
							line += 1; 
							if(i==j && line+6 < tempSizeJ-5){beggining2 += 1; line2 = beggining2;}
							else{line2 = beggining2;}
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
