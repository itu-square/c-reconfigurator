package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.strategies.Strategy
import dk.itu.models.strategies.BottomUpStrategy
import dk.itu.models.rules.SplitConditionalRule
import dk.itu.models.rules.ExtractFunctionRule
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class Test1 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
		var String out1
		var String out2

		// print the unaltered code and AST
		writeToFile(node.printCode, '''«folder»out.c''')
		writeToFile(node.printAST, '''«folder»out.ast''')


		// PHASE 1 - Normalization

		// test that the empty BottomUpStrategy is identity
		out1 = node.printAST(PRINT_HASH_CODE)
		var Strategy bus = new BottomUpStrategy()
		out2 = (bus.transform(node) as Node).printAST(PRINT_HASH_CODE)
		if (out1.equals(out2))
			println("the empty BottomUpStrategy is identity PASS")
		else
			println("the empty BottomUpStrategy is identity FAIL")

		// test RemOneRule
		bus.register(new RemOneRule)
		writeToFile(((bus.transform(node) as Node)).printCode, '''«folder»out_remone.c''')

		// test RemOneRule
		//  and RemExtraRule
		bus.register(new RemExtraRule)
		var Node node1 = bus.transform(node) as Node
		writeToFile(node1.printCode, '''«folder»out_remextra.c''')
		writeToFile(node1.printAST, '''«folder»out_remextra.ast''')
		
		// test SplitConditionalRule
		bus.register(new SplitConditionalRule)
		var Node node2 = bus.transform(node) as Node
		writeToFile(node2.printCode, '''«folder»out_split.c''')
		writeToFile(node2.printAST, '''«folder»out_split.ast''')
		
		
		// PHASE 2 - Extract functions
		bus = new BottomUpStrategy()
		val extfRule = new ExtractFunctionRule
		bus.register(extfRule)
		var Node node3 = bus.transform(node2) as Node
		
		for(String function : extfRule.functions.keySet) {
			println(function)
			for (PresenceCondition pc : extfRule.functions.get(function))
				println("   " + pc)
			println
		}
			
	}

}