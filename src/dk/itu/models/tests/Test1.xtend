package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.strategies.BottomUpStrategy
import dk.itu.models.rules.SplitConditionalRule
import java.io.File
import dk.itu.models.rules.ConditionPushDownRule
import dk.itu.models.strategies.TopDownStrategy
import dk.itu.models.rules.ReconfigureFunctionRule
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import dk.itu.models.rules.PC2ExpressionRule
import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.Reconfigurator

class Test1 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
		// cleanup
		val File f = new File(folder);
		val File[] matchingFiles = f.listFiles[path |
             !path.name.endsWith("in.c")
        ]
        
        matchingFiles.forEach[delete]
		
		// preprocess
		val Preprocessor pp = new Preprocessor();
		pp.run(folder);
		Reconfigurator::transformedFeaturemap = pp.mapFeatureAndTransformedFeatureNames
		
		// transform

		// print the unaltered code and AST
		writeToFile(node.printCode, '''«folder»out.c''')
		writeToFile(node.printAST, '''«folder»out.ast''')


		println("PHASE 1 - Normalization")

		val bus = new BottomUpStrategy()
		bus.register(new RemOneRule)
		bus.register(new RemExtraRule)
		bus.register(new SplitConditionalRule)
		bus.register(new ConditionPushDownRule)

		var Node normalized = bus.transform(node) as Node
		writeToFile(normalized.printCode, '''«folder»normalized.c''')
		writeToFile(normalized.printAST, '''«folder»normalized.ast''')


		
		println("PHASE 2 - Extract functions")

		val tdn = new TopDownStrategy
		val extfRule = new ReconfigureFunctionRule
		tdn.register(extfRule)

		var Node funextracted = tdn.transform(normalized) as Node
		writeToFile(funextracted.printCode, '''«folder»funextracted.c''')
		
//		val tdn1 = new TopDownStrategy
//		tdn1.register(new PC2ExpressionRule)
//		tdn1.transform(normalized)
		
		println("pcidmap")
		println
		println
		extfRule.pcidmap.keySet.forEach[ pc |
			println('''«extfRule.pcidmap.get(pc)»   «pc»''')
		]
		println
		println
//		
//		println("fmap")
//		println
//		println
//		for(String function : extfRule.fmap.keySet) {
//			println(function)
//			for (PresenceCondition pc : extfRule.fmap.get(function)) {
//				println("   " + pc)
//				println('''      «function»_«extfRule.pcidmap.get_id(pc)»''')
//			}
//			println
//		}


		
//		writeToFile(log.toString, folder + "log.txt")
		
	}

}