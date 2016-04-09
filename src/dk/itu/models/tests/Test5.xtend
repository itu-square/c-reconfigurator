package dk.itu.models.tests

import dk.itu.models.Settings
import dk.itu.models.rules.normalize.ConditionPushDownRule
import dk.itu.models.rules.normalize.ConstrainNestedConditionalsRule
import dk.itu.models.rules.normalize.MergeConditionalsRule
import dk.itu.models.rules.normalize.MergeSequentialMutexConditionalRule
import dk.itu.models.rules.normalize.RemOneRule
import dk.itu.models.rules.normalize.RemZeroRule
import dk.itu.models.rules.normalize.SplitConditionalRule
import dk.itu.models.rules.variables.ReconfigureVariableRule
import dk.itu.models.strategies.TopDownStrategy
import java.io.File
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*
import dk.itu.models.rules.normalize.OptimizeAssignmentExpressionRule
import dk.itu.models.rules.NormalizeRule

class Test5 extends Test {
	
	new(String inputFile) {
		super(inputFile)
	}
	
	override transform(Node node) {
		
		writeToFile(node.printCode, file + ".base.c")
		writeToFile(node.printAST, file + ".base.ast")
		
		
		
		println("PHASE 1 - Normalize")
		var Node normalized = node
		
		val tdn0 = new TopDownStrategy
		tdn0.register(new NormalizeRule)
		normalized = tdn0.transform(normalized) as Node
		
//		val tdn1 = new TopDownStrategy
//		tdn1.register(new RemOneRule)
//		tdn1.register(new RemZeroRule)
//		tdn1.register(new SplitConditionalRule)
//		tdn1.register(new ConstrainNestedConditionalsRule)
//		tdn1.register(new ConditionPushDownRule)
//		tdn1.register(new MergeSequentialMutexConditionalRule)
//		normalized = tdn1.transform(normalized) as Node
		
		if(normalized.checkContainsIf1) return;
		
//		val tdn2 = new TopDownStrategy
//		tdn2.register(new MergeConditionalsRule)
//		tdn2.register(new OptimizeAssignmentExpressionRule)
//		normalized = tdn2.transform(normalized) as Node
		
		writeToFile(normalized.printCode, file)
		writeToFile(normalized.printAST, file + ".ast")
		
		println("PHASE 2 - Reconfigure variables")
		
		
		val tdn = new TopDownStrategy
		tdn.register(new ReconfigureVariableRule)
//		tdn.register(new ExtractInitializerRule)
		
		
		var Node varReconfigured = tdn.transform(normalized) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + varReconfigured.printCode»''', file)
		writeToFile(varReconfigured.printAST, file + ".ast")
		
		// check #if elimination
		println('''result: «IF varReconfigured.containsConditional»#if«ELSE»no#if«ENDIF»''')

		// check oracle
		if(Settings::oracleFile != null) {
			val oracle = file.replace(Settings::targetFile.path, Settings::oracleFile.path) + ".ast"
			if((new File(oracle)).exists)
				if(varReconfigured.printAST.equals(readFile(oracle)))
					println("oracle: pass")
				else
					println("oracle: fail")
		}
	}
	
}