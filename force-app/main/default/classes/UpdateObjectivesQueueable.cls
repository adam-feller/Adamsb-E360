public class UpdateObjectivesQueueable implements Queueable {  // WHERE Objective__c IN :objIds
	public List<Objective__c> objectiveList ; 
    
    public UpdateObjectivesQueueable(List<Objective__c> objectiveList){
     	this.objectiveList = objectiveList;
    }
    
    public void execute(QueueableContext context) {
        //Get Objective Ids
        Set<Id> objIds = new Set<Id>();
        for (Objective__c obj : objectiveList) {
            objIds.add(obj.Id);
        }       
        //First Update the Products (in case any new products have been added)        
        ObjectivesController.updateProductsOnObjective(objIds);
                  
		List<Objective_Product__c> objProds = [SELECT Id, Name, Objective__c, Product__r.Id FROM Objective_Product__c WHERE Objective__c IN :objIds];
        for(Objective__c obj : objectiveList) {
			try{                                  
 				//Get the Product Ids
				List<String> productIds = new List<String>();
                for (Objective_Product__c op : objProds) {
                    if (op.Objective__c == obj.Id) {
                        productIds.add(op.Product__r.Id);
                    }
                }
                
				//Get Locations
				List<Objective_Location__c> locations = new List<Objective_Location__c>();
                for (Objective_Location__c loc : obj.Objective_Locations__r) {
                    locations.add(loc);
                }                         
            	ObjectivesController.createObjectives(productIds, obj, true, JSON.serialize(ObjectivesController.getAccountFilterDetails(obj.Id)), false, new List<String>(), new List<String>(), new List<String>(), new List<Objective_Location__c>(), locations, new List<String>(), false);
        	} catch(Exception ex) {
	            if (obj <> null) {
	            	ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'UpdateObjectivesQueueable', 'UpdateObjectivesQueueable.execute(): ' + obj.Id);
	            } else {
	                ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'UpdateObjectivesQueueable', 'UpdateObjectivesQueueable.execute()');
	            }
            }
        }
    }
}