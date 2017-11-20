module Duplication

import Common;
import IO;
import Set;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import Map;


import UnitSize;

//This function gets all the methods and sorts them by LOC. Left is LOC, right are locations. e.g. all methods with 10 LOC look like 10:{loc1,loc2,loc3,...,locn}
map[num lines, set[loc] name] listByLength(){
	methodList = getMethodList(|project://smallsql0.21/src/smallsql|); //Retrieves list from UnitSize.
	//saves all locations in tuples of (LOC, Location);
	list[tuple[num val, loc name]] sizesDupl = [<size(pruneMultilineComments(pruneWhitespaceAndSingleLineComments(readFileLines(method)))),method> | method <- methodList];
	
	//use sort(domain(sizesDupl)); to get a sorted set of the domain to use for matching. 
	
	return toMap(sizesDupl); //Maps all locations with the same length together.
}

list[tuple[list[str] body, loc name]] methodBodies(){
	methodList = getMethodList(|project://smallsql0.21/src/smallsql|);
	list[tuple[list[str] body, loc name]] methodBody = [<pruneMultilineComments(pruneWhitespaceAndSingleLineComments(readFileLines(location)))[1..size(readFileLines(location))-1],location> | location <- methodList ];
	
	return methodBody;
}

list[int dl] duplicationCheck(){

	lengthList = listByLength();
	methodBody = methodBodies();
	int line;
	int beggining;
	list[int duplLines] result;
	
	for ( int i <- [0..size(methodBody)-1] ){
		for (int j <- [(i+1)..size(methodBody)]){
			if(size(methodBody[i].body)>11 && size(methodBody[j].body)>11){
				line = 0;
				while (line < size(methodBody[i].body)-5) {
					if (methodBody[i].body[line] in methodBody[j].body && methodBody[i].body[line+5] in methodBody[j].body){
						
						beggining = line;
						line += 5;
						while (methodBody[i].body[line] in methodBody[j].body){
							line += line;
						}
						if (methodBody[i].body[0..line] < methodBody[j].body){
							result += (line-beggining);
							println(result);
						}
						
					} else {line += 1;} 
				 
				 } //while end
			 }
		} //for j end
	} //for i end
	
	return result;
	
}



CodeProperty computeDuplication(loc project) {
	return <"Duplication", []>;
}
