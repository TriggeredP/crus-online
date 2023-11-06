extends Node

#	Примерная структура syncData (Именно здесь может говно попасть на вентилятор)
#
#	syncData = {
#		assetPath: String,
#		syncProperties: []
#	}

master func sync_nodes():
	for child in get_children():
		if child.has_meta("syncData"):
			print(child.get_meta("syncData"))
			var syncData = {}
			
			for param in child.get_meta("syncData").syncProperties:
				var paramLevel = param.split(".")
				var paramVar = child
				for i in len(paramLevel):
					paramVar = paramVar[paramLevel[i]]
				print(param,paramVar)
				syncData[param] = paramVar
				
			rpc("_spawn_node",child.name,child.get_meta("syncData"),syncData)

puppet func _spawn_node(nodeName,rawSyncData,syncData):
	var syncNodesName = []
	
	for child in get_children():
		syncNodesName.append(child.name)
	
	if not nodeName in syncNodesName:
		var newSyncChild = load(rawSyncData.assetPath).instance()
		newSyncChild.set_name(nodeName)
		newSyncChild.set_meta("syncData",rawSyncData)
		
		self.add_child(newSyncChild)
		
		for param in rawSyncData.syncProperties:
			var paramLevel = param.split(".")
			var paramVar = newSyncChild
			var paramName
			for i in len(paramLevel) - 1:
				paramVar = paramVar[paramLevel[i]]
				paramName = paramLevel[i+1]
			paramVar[paramName] = syncData[param]
		
		if newSyncChild.has_metod("syncUpdate"):
			newSyncChild.call("syncUpdate")

puppet func _delete_node(nodeName):
	pass
