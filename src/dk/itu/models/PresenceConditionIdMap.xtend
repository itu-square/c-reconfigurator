package dk.itu.models

import java.util.HashMap
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class PresenceConditionIdMap {
	private val HashMap<PresenceCondition, String> map
	
	new () {
		this.map = new HashMap<PresenceCondition, String>
	}
	
	public def String getId (PresenceCondition pc) {
		if (map.keySet.findFirst[is(pc)] == null){
			val newId = map.size.toString
			map.put(pc, newId)
			newId
		} else {
			map.get(map.keySet.findFirst[is(pc)])
		}
	}

}