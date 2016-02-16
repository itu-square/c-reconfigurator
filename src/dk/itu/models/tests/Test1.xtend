package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.strategies.Strategy
import dk.itu.models.strategies.BottomUpStrategy
import dk.itu.models.rules.SplitConditionalRule

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

		// test that the empty BottomUpStrategy is identity
		out1 = node.printAST(PRINT_HASH_CODE)
		var Strategy bus = new BottomUpStrategy()
		out2 = (bus.transform(node) as Node).printAST(PRINT_HASH_CODE)
		if (out1.equals(out2))
			println("the empty BottomUpStrategy is identity PASS")
		else
			println("the empty BottomUpStrategy is identity FAIL")

		println("\n\n")

		// test RemOneRule
		bus.register(new RemOneRule)
		writeToFile(((bus.transform(node) as Node)).printCode, '''«folder»out_remone.c''')

		// test RemOneRule
		//  and RemExtraRule
		bus.register(new RemExtraRule)
		writeToFile(((bus.transform(node) as Node)).printCode, '''«folder»out_remextra.c''')
		
		// test RemOneRule
		//  and RemExtraRule
		//  and SplitConditionalRule
		bus.register(new SplitConditionalRule)
		writeToFile(((bus.transform(node) as Node)).printCode, '''«folder»out_split.c''')
	}

}