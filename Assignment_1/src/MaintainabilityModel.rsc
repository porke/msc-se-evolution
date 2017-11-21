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
alias CodePropertyEvaluation = tuple[CodeProperty property,
									 Quality (CodeProperty, list[int]) evaluationFunc,
									 Figure (CodeProperty, list[int]) renderFunc,
									 list[int] thresholds];
alias MaintainabilityModel = list[SystemProperty];
alias Quality = int;

int getThresholdRank(num valueRanked, list[num] thresholds) {
	return size([x | x <- thresholds, valueRanked <= x]) + 1;
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

Quality getVolumeQuality(CodeProperty volume, list[int] thresholds) {	
	num linesOfCodeInThousands = volume.metrics[0].val / 1000;	
	return getThresholdRank(linesOfCodeInThousands, thresholds);
}

Quality getUnitSizeQuality(CodeProperty unitSize, list[int] lineThresholds) {
	// Classification derived from Better Code Hub because it is not in the paper
	int totalLinesOfCode = sum([toInt(x) | x <- unitSize.metrics.val]);
	
	list[list[real]] relativeSizeThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	return getQualityForThresholds([m.val | m <- unitSize.metrics],
									lineThresholds,
									relativeSizeThresholds,
									totalLinesOfCode);
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity, list[int] riskThresholds) {
	// Risk wrt CC: low, moderate, high, very high	
	int totalLinesOfCode = sum([toInt(x) | x <- unitComplexity.metrics.val]); 	// Test data
	list[list[real]] relativeRiskThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	return getQualityForThresholds([m.val | m <- unitComplexity.metrics],
									riskThresholds,
									relativeRiskThresholds,
									totalLinesOfCode);	
}

Quality getDuplicationQuality(CodeProperty duplication, list[int] thresholds) {	
	num duplicationValue = duplication.metrics[0].val;
	int totalLinesOfCode = 12345; 		// TODO: Finish it
	num duplicationPercentage = duplicationValue / totalLinesOfCode;
	return getThresholdRank(duplicationPercentage, thresholds);
}

list[CodePropertyEvaluation] computeCodeProperties(loc project) {
	datetime computationStart = now();	
	datetime stopwatch = now();
	list[CodePropertyEvaluation] ret = [<computeVolume(project), getVolumeQuality, renderVolume, [66, 246, 665, 1310]>];
	println("Volume computed in: <createDuration(stopwatch, now())>");
	
	stopwatch = now();
	ret = ret + <computeUnitSize(project), getUnitSizeQuality, renderUnitSize, [15, 30, 60]>;
	println("Unit size computed in: <createDuration(stopwatch, now())>");
	
	stopwatch = now();
	ret = ret + <computeUnitComplexity(project), getUnitComplexityQuality, renderUnitComplexity, [11, 21, 51]>;
	println("Unit complexity computed in: <createDuration(stopwatch, now())>");
	
	//stopwatch = now();
	//ret = ret + <computeDuplication(project), getDuplicationQuality, renderDuplication, [3, 5, 10, 20]>;	
	//println("Duplication computed in: <createDuration(stopwatch, now())>");
	
	println("All metrics computed in: <createDuration(computationStart, now())>");
	return ret;
}

MaintainabilityModel createMaintainabilityModel(list[CodePropertyEvaluation] props) {	
	return [
			<"Analysability", [pe | pe <- props, pe.property.name == "Volume" || pe.property.name == "Duplication" || pe.property.name == "UnitSize"]>,
			<"Testability", [pe | pe <- props, pe.property.name == "UnitComplexity" || pe.property.name == "UnitSize"]>,
			<"Changeability", [pe | pe <- props, pe.property.name == "Duplication" || pe.property.name == "UnitComplexity"]>
			];
}

Quality getSystemPropertyQuality(SystemProperty prop) {
	return sum([0] + [pe.evaluationFunc(pe.property, pe.thresholds) | pe <- prop.properties]) / size(prop.properties);
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
	Quality q = prop.evaluationFunc(prop.property, prop.thresholds);
	return tree(box(text("<prop.property.name>: <qualityToString(q)>"), qualityToColor(q)), [prop.renderFunc(prop.property, prop.thresholds)]);
}

Figure renderVolume(CodeProperty prop, list[int] thresholds) {
	return box(grid([[box(text(m.name)), box(text("<m.val>"))] | m <- prop.metrics]));
}

Figure renderUnitSize(CodeProperty prop, list[int] thresholds) {
	real totalLines = toReal(sum([m.val | m <- prop.metrics]));
	rel[int, num] valuesByCategory = getAggregatedValueCounts([m.val | m <- prop.metrics], thresholds);
	list[tuple[str name, num val]] sizeCategories = [<"Low (0-<thresholds[0]> LOC)", round(sum(valuesByCategory[1]) / totalLines * 100, 0.1)>,
													 <"Medium (<thresholds[0]>-<thresholds[1]> LOC)", round(sum(valuesByCategory[2]) / totalLines * 100, 0.1)>,
													 <"High (<thresholds[1]>-<thresholds[2]> LOC)", round(sum(valuesByCategory[3]) / totalLines * 100, 0.1)>,
													 <"Very high (<thresholds[2]>+ LOC)", round(sum(valuesByCategory[4]) / totalLines * 100, 0.1)>];
	list[Figure] captionRow = [box(text("Risk")), box(text("% LOC"))];
	return box(grid([captionRow] + [[box(text(s.name)), box(text("<s.val>"))] | s <- sizeCategories]));
}

Figure renderUnitComplexity(CodeProperty prop, list[int] thresholds) {	
	rel[int, num] valuesByCategory = getAggregatedValueCounts([m.val | m <- prop.metrics], thresholds);
	real totalLines = 1.0;
	list[tuple[str name, num val]] complexityCategories = [<"Low (0-<thresholds[0]> LOC)", round(sum(valuesByCategory[1]) / totalLines * 100, 0.1)>,
													 <"Medium (<thresholds[0]>-<thresholds[1]> LOC)", round(sum(valuesByCategory[2]) / totalLines * 100, 0.1)>,
													 <"High (<thresholds[1]>-<thresholds[2]> LOC)", round(sum(valuesByCategory[3]) / totalLines * 100, 0.1)>,
													 <"Very high (<thresholds[2]>+ LOC)", round(sum(valuesByCategory[4]) / totalLines * 100, 0.1)>];
	list[Figure] captionRow = [box(text("Risk")), box(text("% code"))];
	return box(grid([captionRow] + [[box(text(s.name)), box(text("<s.val>"))] | s <- complexityCategories]));
}

Figure renderDuplication(CodeProperty prop, list[int] thresholds) {
	return box(grid([[box(text(m.name)), box(text("<m.val>"))] | m <- prop.metrics]));
}

//////////////////////////////////////////////////
// Test code
//////////////////////////////////////////////////

void performanceTest() {
	loc project = |project://hsqldb-2.3.1/hsqldb/src|;
	computeModel(project);
}

void computeModel() {
	loc project = |project://smallsql0.21/src|;
	computeModel(project);
}
