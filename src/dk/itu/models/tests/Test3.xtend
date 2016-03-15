package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.SplitConditionalRule
import dk.itu.models.rules.ConditionPushDownRule
import dk.itu.models.strategies.TopDownStrategy
import dk.itu.models.rules.ReconfigureFunctionRule
import dk.itu.models.rules.RemSequentialMutexConditionalRule
import dk.itu.models.rules.RemNestedMutexConditionalRule
//import dk.itu.models.rules.ExtractFirstRule
//import dk.itu.models.rules.MergeSequencesRule
import static extension dk.itu.models.Extensions.*
import dk.itu.models.Settings
import java.io.File

class Test3 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
////		println(file)
//		writeToFile(node.printCode, file + "base.c")
////		writeToFile(node.printAST, file + ".ast")

		println("PHASE 1 - Normalize")
		
		val tdn = new TopDownStrategy
		tdn.register(new RemOneRule)
		tdn.register(new RemExtraRule)
		tdn.register(new RemSequentialMutexConditionalRule)
		tdn.register(new RemNestedMutexConditionalRule)
		tdn.register(new SplitConditionalRule)
		tdn.register(new ConditionPushDownRule)
//		tdn.register(new MergeSequencesRule)
//		tdn.register(new ExtractFirstRule)
//
		var Node normalized = tdn.transform(node) as Node
		writeToFile(normalized.printCode, file + "norm.c")
		writeToFile(normalized.printAST, file + "norm.ast")
		
		println("PHASE 2 - Extract functions")

		val tdn1 = new TopDownStrategy
		tdn1.register(new ReconfigureFunctionRule)

		var Node funextracted = tdn1.transform(normalized) as Node
		writeToFile(funextracted.printCode, file)
		writeToFile(funextracted.printAST, file + ".ast")

		// check #if elimination
		println('''result: «IF funextracted.containsConditional»#if«ELSE»   «ENDIF»''')

		// check oracle
		if(Settings::oracleFile != null) {
			val oracle = file.replace(Settings::targetFile.path, Settings::oracleFile.path) + ".ast"
			if((new File(oracle)).exists)
				if(funextracted.printAST.equals(readFile(oracle)))
					println("oracle: pass")
				else
					println("oracle: fail")
		}
	}

}