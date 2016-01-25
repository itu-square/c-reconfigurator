package itu

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import java.util.List
import xtc.lang.cpp.CTag

interface Tx {
	def PresenceCondition tx_start(PresenceCondition condition, List<Node> ancestors)

	def void tx_end(PresenceCondition condition, List<Node> ancestors)

	def Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors)

	def void tx_end(Language<CTag> language, List<Node> ancestors)

	def GNode tx_start(GNode node, List<Node> ancestors)

	def void tx_end(GNode node, List<Node> ancestors)

	def Node tx_start(Node node, List<Node> ancestors)

	def void tx_end(Node node, List<Node> ancestors)

}
