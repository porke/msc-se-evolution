module MaintainabilityModelRenderer

import util::Math;
import vis::Render;
import vis::Figure;
import List;

import Common;
import MaintainabilityModel;


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
								[renderSystemProperty(<p, qualitiesPerSystemProperty[p]>) | p <- qualitiesPerSystemProperty], 
								std(gap(20)));
	render(modelFigure);
}

Figure renderSystemProperty(tuple[SystemProperty, Quality] prop) {
	Quality q = prop[1];
	return tree(ellipse(text("<prop[0].name>: (<qualityToString(q)>)"), qualityToColor(q)), [renderCodeProperty(c) | c <- prop[0].properties]);
}

Figure renderCodeProperty(CodePropertyEvaluation prop) {
	Quality q = prop.evaluationFunc(prop.property, prop.thresholds);
	map[str, Figure (CodeProperty, list[int])] renderFunctions = ("Volume" : renderVolume,
																  "Duplication" : renderDuplication,
																  "UnitSize" : renderUnitSize,
												 				  "UnitComplexity" : renderUnitComplexity);
	
	return tree(box(text("<prop.property.name>: <qualityToString(q)>"), qualityToColor(q)), [renderFunctions[prop.property.name](prop.property, prop.thresholds)]);
}

Figure renderVolume(CodeProperty prop, list[int] thresholds) {
	return box(grid([[box(text(m.name)), box(text("<m.val>"))] | m <- prop.metrics]));
}

Figure renderUnitSize(CodeProperty prop, list[int] thresholds) {
	real totalLines = toReal(sum([m.val | m <- prop.metrics]));
	map[int, num] valuesByCategory = getAggregatedValueCounts([m.val | m <- prop.metrics], thresholds);
	list[tuple[str name, num val]] sizeCategories = [<"Low (0-<thresholds[0]> LOC)", round(valuesByCategory[1] / totalLines * 100, 0.1)>,
													 <"Medium (<thresholds[0]>-<thresholds[1]> LOC)", round(valuesByCategory[2] / totalLines * 100, 0.1)>,
													 <"High (<thresholds[1]>-<thresholds[2]> LOC)", round(valuesByCategory[3] / totalLines * 100, 0.1)>,
													 <"Very high (<thresholds[2]>+ LOC)", round(valuesByCategory[4] / totalLines * 100, 0.1)>];
	list[Figure] captionRow = [box(text("Unit Risk")), box(text("% LOC"))];
	return box(grid([captionRow] + [[box(text(s.name)), box(text("<s.val>"))] | s <- sizeCategories]));
}

Figure renderUnitComplexity(CodeProperty prop, list[int] thresholds) {	
	real totalComplexity = toReal(sum([m.val | m <- tail(prop.metrics)]));
	map[int, num] valuesByCategory = getAggregatedValueCounts([m.val | m <- tail(prop.metrics)], thresholds);
	list[tuple[str name, num val]] complexityCategories = [<"Low (0-<thresholds[0]> CC)", round(valuesByCategory[1] / totalComplexity * 100, 0.1)>,
													 <"Medium (<thresholds[0]>-<thresholds[1]> CC)", round(valuesByCategory[2] / totalComplexity * 100, 0.1)>,
													 <"High (<thresholds[1]>-<thresholds[2]> CC)", round(valuesByCategory[3] / totalComplexity * 100, 0.1)>,
													 <"Very high (<thresholds[2]>+ CC)", round(valuesByCategory[4] / totalComplexity * 100, 0.1)>];
	list[Figure] captionRow = [box(text("Unit Risk")), box(text("% CC"))];
	return box(grid([captionRow] + [[box(text(s.name)), box(text("<s.val>"))] | s <- complexityCategories]));
}

Figure renderDuplication(CodeProperty prop, list[int] thresholds) {
	list[Figure] newBox = [box(text("Percentage")), box(text("<round((prop.metrics[0].val/(prop.metrics[1].val*1.0))*100,0.001)>%"))];
	return box(grid([[box(text(m.name)), box(text("<m.val>"))] | m <- prop.metrics] + [newBox]));
}


//////////////////////////////////////////////////
// Test code
//////////////////////////////////////////////////

void renderModel() {
	loc project = |project://smallsql0.21/src|;
	renderModel(computeModel(project));
}
