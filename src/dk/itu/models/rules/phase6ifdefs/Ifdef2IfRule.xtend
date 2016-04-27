package dk.itu.models.rules.phase6ifdefs

import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import xtc.lang.cpp.Syntax.Text

class Ifdef2IfRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		
		if (
			node.name.equals("Conditional")
			&& #["AdditiveExpression", "Initializer", "ExpressionStatement", "ReturnStatement",
				"MultiplicativeExpression", "PrimaryExpression"].contains(ancestors.last.name)
		) {
			//            List<     Map<        OriginalPC,        SimplifiedPC>>
			val pcs = new ArrayList<SimpleEntry<PresenceCondition, PresenceCondition>>
			
			var disPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
			for (PresenceCondition pc : node.filter(PresenceCondition)) {
				val newPC = Reconfigurator::presenceConditionManager.newPresenceCondition(pc.BDD.constrain(disPC.BDD.not))
				pcs.add(new SimpleEntry(pc, newPC))
				disPC = disPC.or(pc)
			}
			
			var Node exp = null
			if (!node.presenceCondition.getBDD.imp(disPC.getBDD).isOne) {
				exp = GNode::create(
					"FunctionCall",
					GNode::create(
						"PrimaryIdentifier",
						new Text(CTag::IDENTIFIER, "_reconfig_skip")),
					new Language<CTag>(CTag::LPAREN),
					new Language<CTag>(CTag::RPAREN))
			}
			
			for (SimpleEntry<PresenceCondition, PresenceCondition> map : pcs.reverseView) {
				if (node.getChildrenGuardedBy(map.key).size != 1) {
					println('''- Ifdef2IfRule: PresenceCondition guarding multiple children.''')
					println('''- «node.getChildrenGuardedBy(map.key).size»''')
					node.getChildrenGuardedBy(map.key).forEach[println('''- «it»''')]
					println(node.printAST)
					throw new Exception("Ifdef2IfRule: PresenceCondition guarding multiple children.")
				}
				
				if (exp == null) { // and pc.isTrue because of previous check
					exp = node.getChildrenGuardedBy(map.key).get(0) as Node
				} else {
					exp = GNode::create("PrimaryExpression",
						new Language<CTag>(CTag.LPAREN),
				 		GNode::create("ConditionalExpression",
				 			map.value.PCtoCexp,
				 			new Language<CTag>(CTag.QUESTION),
				 			node.getChildrenGuardedBy(map.key).get(0),
				 			new Language<CTag>(CTag.COLON),
				 			exp
				 			),
				 		new Language<CTag>(CTag.RPAREN))
				}
			}
			return exp
		} else if (
			node.name.equals("Conditional")
			&& #["DeclarationOrStatementList", "CompoundStatement"].contains(ancestors.last.name)
		) {	
			//            List<     Map<        OriginalPC,        SimplifiedPC>>
			val pcs = new ArrayList<SimpleEntry<PresenceCondition, PresenceCondition>>
			
			var disPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
			for (PresenceCondition pc : node.filter(PresenceCondition)) {
				val newPC = Reconfigurator::presenceConditionManager.newPresenceCondition(pc.BDD.constrain(disPC.BDD.not))
				pcs.add(new SimpleEntry(pc, newPC))
				disPC = disPC.or(pc)
			}

			var GNode exp = null
			var GNode lastexp = null
			
			for (SimpleEntry<PresenceCondition, PresenceCondition> map : pcs) {
				if (map == pcs.head) {
					exp = GNode::create("SelectionStatement")
					exp = exp.add(new Language<CTag>(CTag::^IF))
						.add(new Language<CTag>(CTag::LPAREN))
						.add((node.get(0) as PresenceCondition).PCtoCexp)
						.add(new Language<CTag>(CTag::RPAREN))
						.add(new Language<CTag>(CTag::LBRACE))
						.addAll(node.getChildrenGuardedBy(map.key))
						.add(new Language<CTag>(CTag::RBRACE)) as GNode
					lastexp = exp
				} else if (map != pcs.last) {
					var newexp = GNode::create("SelectionStatement")
					newexp = newexp.add(new Language<CTag>(CTag::^IF))
							.add(new Language<CTag>(CTag::LPAREN))
							.add((node.get(0) as PresenceCondition).PCtoCexp)
							.add(new Language<CTag>(CTag::RPAREN))
							.add(new Language<CTag>(CTag::LBRACE))
							.addAll(node.getChildrenGuardedBy(map.key))
							.add(new Language<CTag>(CTag::RBRACE)) as GNode
					lastexp.add(new Language<CTag>(CTag::^ELSE))
					lastexp.add(newexp)
					lastexp = newexp
				} else { // map == pcs.last
					lastexp.add(new Language<CTag>(CTag::^ELSE))
						.add(new Language<CTag>(CTag::LBRACE))
						.addAll(node.getChildrenGuardedBy(map.key))
						.add(new Language<CTag>(CTag::RBRACE))
				}
			}
			return exp
		} else if (
			node.name.equals("Conditional")
		) {
			println
			ancestors.forEach[
				println('''- «it»''')]
			println(node.printAST)
			throw new Exception("Ifdef2IfRule: unexpected Conditional context")
		}
		
		node
	}

}