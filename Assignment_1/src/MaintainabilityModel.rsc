module MaintainabilityModel

import util::Math;
import List;

import Common;
import Duplication;
import Volume;
import UnitComplexity;
import UnitSize;
import IO;

alias SystemProperty = tuple[str name, list[CodePropertyEvaluation] properties];
alias CodePropertyEvaluation = tuple[CodeProperty property, Quality (CodeProperty) evaluationFunc];
alias Quality = int;

Quality MinQuality = 1;
Quality MaxQuality = 5;

Quality getVolumeQuality(CodeProperty volume) {
	// TODO: usage table to grade
	return MinQuality;
}

Quality getUnitSizeQuality(CodeProperty unitSize) {
	// TODO: usage table to grade
	return MinQuality;
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity) {
	// TODO: usage table to grade
	return MinQuality;
}

Quality getDuplicationQuality(CodeProperty duplication) {
	// TODO: usage table to grade
	return MinQuality;
}

list[CodePropertyEvaluation] computeCodeProperties(loc project) {
	return [<computeVolume(project), getVolumeQuality>,
			<computeUnitSize(project), getUnitSizeQuality>,
			<computeUnitComplexity(project), getUnitComplexityQuality>,
			<computeDuplication(project), getDuplicationQuality>];
}

list[SystemProperty] createSystemProperties(list[CodePropertyEvaluation] props) {
	SystemProperty stability = <"Stability", []>;
	SystemProperty analysability = <"Analysability", [pe | pe <- props, pe.property.name == "Volume" || pe.property.name == "Duplication" || pe.property.name == "UnitSize"]>;
	SystemProperty testability = <"Testability", [pe | pe <- props, pe.property.name == "UnitComplexity" || pe.property.name == "UnitSize"]>;
	SystemProperty changeability = <"Changeability", [pe | pe <- props, pe.property.name == "Duplication" || pe.property.name == "UnitComplexity"]>;
	return [stability, analysability, testability, changeability];
}

Quality getSystemPropertyQuality(SystemProperty prop) {
	return sum([0] + [pe.evaluationFunc(pe.property) | pe <- prop.properties]) / size(prop.properties);
}

void computeModel(loc project) {
	list[CodePropertyEvaluation] codeProperties = computeCodeProperties(project);
	list[SystemProperty] systemProperties = createSystemProperties(codeProperties);
	iprintln([<sp.name, getSystemPropertyQuality(sp), [<cp.property.name, cp.evaluationFunc(cp.property)> | cp <- sp.properties]> | sp <- systemProperties]);	
	
	// TODO: visualize the model?
}
