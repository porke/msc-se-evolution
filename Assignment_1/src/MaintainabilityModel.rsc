module MaintainabilityModel

import util::Math;
import List;
import Set;
import Relation;
import Map;
import IO;
import vis::Render;
import vis::Figure;
import DateTime;

import Common;
import Duplication;
import Volume;
import UnitComplexity;
import UnitSize;

alias SystemProperty = tuple[str name, list[CodePropertyEvaluation] properties];
alias CodePropertyEvaluation = tuple[CodeProperty property, Quality (CodeProperty) evaluationFunc, Figure (CodeProperty) renderFunc];
alias MaintainabilityModel = list[SystemProperty];
alias Quality = int;

int getThresholdRank(num valueRanked, list[num] thresholds) {
	return size([x | x <- thresholds, valueRanked <= x]) + 1;
}

Quality getVolumeQuality(CodeProperty volume) {
	list[int] thresholds = [66, 246, 665, 1310];
	num linesOfCodeInThousands = volume.metrics[0].val / 1000;	
	return getThresholdRank(linesOfCodeInThousands, thresholds);
}

rel[int, num] getAggregatedValueCounts(list[num] metricValues,
									   list[int] thresholdValues) {
	int minRank = 1;
	int maxRank = size(thresholdValues) + 1;
	list[int] thresholdRanks = [minRank..(maxRank+1)];
	
	list[tuple[int rank, int lines]] valueByThreshold = [<1 + maxRank - getThresholdRank(m, thresholdValues), toInt(m)> | m <- metricValues];	
	return {<threshold, sum([x.lines | x <- valueByThreshold, x.rank == threshold])> | threshold <- thresholdRanks};
}

list[real] getValueCategories(rel[int, num] aggregatedValueCounts, int totalValue, list[int] thresholdRanks) {
	return [toReal(sum(aggregatedValueCounts[rank])) / toReal(totalValue) | rank <- thresholdRanks];
}

Quality getQualityForThresholds(list[num] metricValues,
							   	list[int] thresholdValues,
							   	list[list[real]] categoryThresholds,
								int totalValue) {
	int minRank = 1;
	int maxRank = size(thresholdValues) + 1;
	list[int] thresholdRanks = [minRank..(maxRank+1)];
								
	// Map the aggregated values to percentages of code in each categories
	rel[int, num] aggregatedValueCounts = getAggregatedValueCounts(metricValues, thresholdValues);	
	list[real] valueCategories = getValueCategories(aggregatedValueCounts, totalValue, thresholdRanks);	
	// Thresholds for low, medium, high and very high risk code
	list[int] qualitiesPerSizeCategory = [getThresholdRank(valueCategories[x - 1], categoryThresholds[x - 1]) | x <- thresholdRanks];    
	return min(qualitiesPerSizeCategory);
}

Quality getUnitSizeQuality(CodeProperty unitSize) {
	// Classification derived from Better Code Hub because it is not in the paper
	list[int] lineThresholds = [15, 30, 60];	
	int totalLinesOfCode = sum([toInt(x) | x <- unitSize.metrics.val]);
	
	iprintln(unitSize.metrics);
	list[list[real]] relativeSizeThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	return getQualityForThresholds([m.val | m <- unitSize.metrics],
									lineThresholds,
									relativeSizeThresholds,
									totalLinesOfCode);
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity) {
	// Risk wrt CC: low, moderate, high, very high
	list[int] riskThresholds = [11, 21, 51];
	int totalLinesOfCode = sum([toInt(x) | x <- unitComplexity.metrics.val]); 	// Test data
	list[list[real]] relativeRiskThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	return getQualityForThresholds([m.val | m <- unitComplexity.metrics],
									riskThresholds,
									relativeRiskThresholds,
									totalLinesOfCode);	
}

Quality getDuplicationQuality(CodeProperty duplication) {
	list[real] thresholds = [0.03, 0.05, 0.1, 0.2];
	int totalLinesOfCode = 12345; 	// Test data
	num duplicationValue = duplication.metrics[0].val; 
	num duplicationPercentage = duplicationValue / totalLinesOfCode;
	return getThresholdRank(duplicationPercentage, thresholds);
}

list[CodePropertyEvaluation] computeCodeProperties(loc project) {
	datetime computationStart = now();	
	datetime stopwatch = now();
	list[CodePropertyEvaluation] ret = [<computeVolume(project), getVolumeQuality, renderVolume>];
	println("Volume computed in: <createDuration(stopwatch, now())>");
	
	stopwatch = now();
	ret = ret + <computeUnitSize(project), getUnitSizeQuality, renderUnitSize>;
	println("Unit size computed in: <createDuration(stopwatch, now())>");
	//
	//stopwatch = now();
	//ret = ret + <computeUnitComplexity(project), getUnitComplexityQuality, renderUnitComplexity>;
	//println("Unit complexity computed in: <createDuration(stopwatch, now())>");
	//
	//stopwatch = now();
	//ret = ret + <computeDuplication(project), getDuplicationQuality, renderDuplication>;	
	//println("Duplication computed in: <createDuration(stopwatch, now())>");
	
	println("All metrics computed incomputed in: <createDuration(computationStart, now())>");
	return ret;
}

MaintainabilityModel createMaintainabilityModel(list[CodePropertyEvaluation] props) {	
	return [
			<"Analysability", [pe | pe <- props, pe.property.name == "Volume" || pe.property.name == "Duplication" || pe.property.name == "UnitSize"]>
			//<"Testability", [pe | pe <- props, pe.property.name == "UnitComplexity" || pe.property.name == "UnitSize"]>,
			//<"Changeability", [pe | pe <- props, pe.property.name == "Duplication" || pe.property.name == "UnitComplexity"]>
			];
}

Quality getSystemPropertyQuality(SystemProperty prop) {
	return sum([0] + [pe.evaluationFunc(pe.property) | pe <- prop.properties]) / size(prop.properties);
}

void computeModel(loc project) {
	list[CodePropertyEvaluation] codeProperties = computeCodeProperties(project);
	MaintainabilityModel systemProperties = createMaintainabilityModel(codeProperties);
	renderModel(systemProperties);
}

//////////////////////////////////////////////////
// Visualization code
//////////////////////////////////////////////////
FProperty qualityToColor(Quality q) {
	map[Quality, FProperty] qToCol = (1 : fillColor("red"),
									  2 : fillColor("orange"),
									  3 : fillColor("yellow"),
									  4 : fillColor("green"),
									  5 : fillColor("darkGreen"));
	return qToCol[q];
}

str qualityToString(Quality q) {
	map[Quality, str] qToStr = (0 : "?",
								1 : "--",
								2 : "-",
								3 : "o",
								4 : "+",
								5 : "++");
	return qToStr[q];
}

void renderModel(MaintainabilityModel model) {
	map[SystemProperty, Quality] qualitiesPerSystemProperty =  (p : getSystemPropertyQuality(p) | p <- model);
	Quality overallQuality = sum([qualitiesPerSystemProperty[p] | p <- model]) / size(model);
	Figure modelFigure = tree(box(text("Maintainability: (<qualityToString(overallQuality)>)"), qualityToColor(overallQuality)), 
								[renderSystemProperty(p) | p <- toList(qualitiesPerSystemProperty)], 
								std(gap(20)));
	render(modelFigure);
}

Figure renderSystemProperty(tuple[SystemProperty, Quality] prop) {
	Quality q = prop[1];
	return tree(ellipse(text("<prop[0].name>: (<qualityToString(q)>)"), qualityToColor(q)), [renderCodeProperty(c) | c <- prop[0].properties]);
}

Figure renderCodeProperty(CodePropertyEvaluation prop) {
	Quality q = prop.evaluationFunc(prop.property);
	return tree(box(text("<prop.property.name>: <qualityToString(q)>"), qualityToColor(q)), [prop.renderFunc(prop.property)]);
}

Figure renderVolume(CodeProperty prop) {
	return box(grid([[box(text(m.name)), box(text("<m.val>"))] | m <- prop.metrics]));
}

Figure renderUnitSize(CodeProperty prop) {
	// TODO: compute size categories	
	list[tuple[str name, real val]] sizeCategories = [<"Low", 0.1>, <"Medium", 0.2>, <"High", 0.3>, <"Very high", 0.4>];
	list[Figure] captionRow = [box(text("Risk")), box(text("% code"))];
	return box(grid([captionRow] + [[box(text(s.name)), box(text("<s.val>"))] | s <- sizeCategories]));
}

Figure renderUnitComplexity(CodeProperty prop) {
	// TODO: compute complexity categories
	list[tuple[str name, real val]] sizeCategories = [<"Low", 0.1>, <"Medium", 0.2>, <"High", 0.3>, <"Very high", 0.4>];
	list[Figure] captionRow = [box(text("Risk")), box(text("% code"))];
	return box(grid([captionRow] + [[box(text(s.name)), box(text("<s.val>"))] | s <- sizeCategories]));
}

Figure renderDuplication(CodeProperty prop) {
	return box(grid([[box(text(m.name)), box(text("<m.val>"))] | m <- prop.metrics]));
}

//////////////////////////////////////////////////
// Test code
//////////////////////////////////////////////////

void performanceTest() {
	loc project = |project://hsqldb-2.3.1/hsqldb/src|;
	computeModel(project);
}

void testVolume() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeVolume(project);
	render(renderVolume(property));
}

void computeModel() {
	loc project = |project://smallsql0.21/src|;
	computeModel(project);
}

void computeUnitSizeQuality() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeUnitSize(project); 
	iprintln(getUnitSizeQuality(property));
}

void computeVolumeQuality() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeVolume(project); 
	iprintln(getVolumeQuality(property));
}

void computeUnitComplexityQuality() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeUnitComplexity(project); 
	iprintln(getUnitComplexityQuality(property));
}