package dk.itu.models.tests

import dk.itu.models.rules.ConstrainNestedConditionalsRule
import dk.itu.models.rules.RemOneRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.tree.Node
import dk.itu.models.rules.ConditionPushDownRule
import dk.itu.models.rules.MergeConditionalsRule
import dk.itu.models.rules.MergeSequentialMutexConditionalRule

import static extension dk.itu.models.Extensions.*
import dk.itu.models.Settings
import dk.itu.models.rules.ReconfigureVariableRule
import java.io.File
import dk.itu.models.rules.SplitConditionalRule
import dk.itu.models.rules.RemZeroRule

class Test5 extends Test {
	
	new(String inputFile) {
		super(inputFile)
	}
	
	override transform(Node node) {
		
		writeToFile(node.printCode, file)
		
		
		
		println("PHASE 1 - Normalize")
		
		val tdn1 = new TopDownStrategy
		tdn1.register(new RemOneRule)
		tdn1.register(new RemZeroRule)
		tdn1.register(new SplitConditionalRule)
		tdn1.register(new ConstrainNestedConditionalsRule)
		tdn1.register(new ConditionPushDownRule)
		tdn1.register(new MergeSequentialMutexConditionalRule)
		
		var Node normalized = tdn1.transform(node) as Node
		writeToFile(normalized.printCode, file)
		writeToFile(normalized.printAST, file + ".ast")
		
		if(normalized.checkContainsIf1) return
		
		
		
		val tdn2 = new TopDownStrategy
		tdn2.register(new MergeConditionalsRule)
		
		var Node normalized2 = tdn2.transform(normalized) as Node
		writeToFile(normalized2.printCode, file)
		
		println("PHASE 2 - Reconfigure variables")
		
		
		val tdn = new TopDownStrategy
		tdn.register(new ReconfigureVariableRule)
//		tdn.register(new ExtractInitializerRule)
		
		
		var Node varReconfigured = tdn.transform(normalized2) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + varReconfigured.printCode»''', file)
		writeToFile(varReconfigured.printAST, file + ".ast")
		
		// check #if elimination
		println('''result: «IF varReconfigured.containsConditional»#if«ELSE»   «ENDIF»''')

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