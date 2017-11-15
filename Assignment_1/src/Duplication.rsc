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
map[num, set[loc]] listByLength(){
	methodList = getMethodList(|project://smallsql0.21/|); //Retrieves list from UnitSize.
	//saves all locations in tuples of (LOC, Location);
	list[tuple[num val, loc name]] sizesDupl = [<size(pruneMultilineComments(pruneWhitespaceAndSingleLineComments(readFileLines(method)))),method> | method <- methodList];
	
	//use sort(domain(sizesDupl)); to get a sorted set of the domain to use for matching. 
	
	return toMap(sizesDupl); //Maps all locations with the same length together.
}

//USE THIS TO CHECK FOR SIMILAR CONTENT. ignore method names as they are not similar and check for content?
//Or similarly use expression check.

CodeProperty computeDuplication(loc project) {
	return <"Duplication", []>;
}
