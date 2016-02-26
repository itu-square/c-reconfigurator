//package dk.itu.models.strategies
//
//import dk.itu.models.rules.Rule
//import xtc.lang.cpp.CTag
//import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
//import xtc.lang.cpp.Syntax.Language
//import xtc.tree.GNode
//import xtc.util.Pair
//
//class TopDownStrategy extends Strategy {
//
//	override dispatch PresenceCondition transform(PresenceCondition cond) {
////		println('''bus �cond�''')
////		manager.newPresenceCondition(cond.BDD)
//		cond
//	}
//
//	override dispatch Language<CTag> transform(Language<CTag> lang) {
////		println('''bus �lang�''')
////		lang.copy
//		lang
//	}
//
//	override dispatch Pair<?> transform(Pair<?> pair) {
//		if (pair.isEmpty)
//			pair
//		else {
//
//			var Pair<?> newTail = transform(pair.tail) as Pair<?>
//			var Object newHead = transform(pair.head)
//
//			var Pair<?> newPair = new Pair(newHead, newTail)
//
////			println('''bus �pair�''')
//			var Pair<?> prev = null
//			while (newPair != prev) {
//				prev = newPair
//				for (Rule rule : rules) {
//					newPair = rule.transform(newPair) as Pair<?>
//				}
//			}
//
//			newPair
//		}
//	}
//
//	override dispatch Object transform(GNode node) {
//		var Object newNode = node
//
////		println('''bus �node�''')
//		var Object prev = null
//		while (newNode != prev) {
//			prev = newNode
//			for (Rule rule : rules) {
//				newNode = rule.transform(newNode)
//			}
//		}
//		
//		if (newNode instanceof GNode) {
//			ancestors.add(newNode as GNode)
//	
//			var Object newerNode = GNode::create(newNode.name)
//			(newerNode as GNode).addAll(transform(newNode.toPair) as Pair<?>)
//	
//			ancestors.remove(newNode as GNode)
//		}
//		newNode
//	}
//
//}