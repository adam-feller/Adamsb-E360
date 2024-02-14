public class ObjectivePDFParameterController {
    
    @AuraEnabled
	public static Objective__c getObjective(String recordId) {
        Objective__c obj =  [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c WHERE Id =:recordId];    	
    	return obj;
	}

    @AuraEnabled
	public static List<Map<String, String>> getObjectives(String search, String show, List<String> selectedObjectives) {
    	List<Map<String, String>> items = new List<Map<String, String>>();
        //We only want these types of Objectives returned
        List<String> objTypes = new List<String>{'Display','Price Feature','Reset'};
        //Search String
        String searchString = '%' + search + '%';
        //First get the Objectives that have been selected
        for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c WHERE Parent_Child_Independent__c != 'Cascade' AND Id IN :selectedObjectives ORDER BY Name ASC]) {            
			items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});
		}        
        //Than get all the other objectives based on the criteria
        if (show == 'All' || show == '') {
        	if (search != '') {
	    		for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c 
                                         WHERE Objective_Type__c IN :objTypes AND Parent_Child_Independent__c != 'Cascade' 
                                         AND Name LIKE :searchString AND Id NOT IN: selectedObjectives ORDER BY Name ASC]) {
		           	items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});
		        }
		    } else {
	    		for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c 
                                         WHERE Objective_Type__c IN :objTypes AND Parent_Child_Independent__c != 'Cascade' 
                                         AND Id NOT IN: selectedObjectives ORDER BY Name ASC]) {               
		            items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});                    
		        }            
	        }
        } else if (show == 'Active') {
        	if (search != '') {
	    		for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c 
                                         WHERE Objective_Type__c IN :objTypes AND Parent_Child_Independent__c != 'Cascade' 
                                         AND Name LIKE :searchString AND Active__c = true AND Id NOT IN: selectedObjectives ORDER BY Name ASC]) { 
		            items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});
		        }
		    } else {
	    		for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c 
                                         WHERE Objective_Type__c IN :objTypes AND Parent_Child_Independent__c != 'Cascade' 
                                         AND Active__c = true AND Id NOT IN: selectedObjectives ORDER BY Name ASC]) {
		            items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});
		        }            
	        }            
        } else {
        	if (search != '') {	        	
	    		for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c 
                                         WHERE Objective_Type__c IN :objTypes AND Parent_Child_Independent__c != 'Cascade' 
                                         AND Name LIKE :searchString AND Active__c = false AND Id NOT IN: selectedObjectives ORDER BY Name ASC]) {            
		            items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});
		        }
		    } else {
	    		for (Objective__c obj : [SELECT Id, Start_Date__c, End_Date__c, Name FROM Objective__c 
                                         WHERE Objective_Type__c IN :objTypes AND Parent_Child_Independent__c != 'Cascade' 
                                         AND Active__c = false AND Id NOT IN: selectedObjectives ORDER BY Name ASC]) {            
                    items.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name + ' (' + obj.Start_Date__c.format() + ' - ' + obj.End_Date__c.format() + ')'});
		        }
	        }             
        }
        if (items.size() <= 0) {
            items.add(new Map<String, String>{'value' => 'None Found', 'label' => 'None Found'});
        }        
    	return items;
	}   
        
    @AuraEnabled
	public static List<Map<String, String>> getLocations(String ids) {        
    	List<Map<String, String>> items = new List<Map<String, String>>();        
        if (ids != '') {            
        	List<Id> objIds = ids.split(';');
			String currLocation = '';
    		for (Objective_Submission__c sub : [SELECT Id, Objective_Account__r.Account__r.VIP_Instance__c, Objective_Account__r.Account__r.SalesOrg__c, Objective_Account__r.Account__r.Warehouse__c
                                                FROM Objective_Submission__c WHERE Objective_Account__r.Objective__r.Id IN :objIds AND Status__c = 'Approved' ORDER BY Objective_Account__r.Account__r.VIP_Instance__c, Objective_Account__r.Account__r.SalesOrg__c, Objective_Account__r.Account__r.Warehouse__c ASC]) {                
				if (sub.Objective_Account__r.Account__r.VIP_Instance__c + ' / ' + sub.Objective_Account__r.Account__r.SalesOrg__c + ' / ' + sub.Objective_Account__r.Account__r.Warehouse__c != currLocation) {
					items.add(new Map<String, String>{'value' => sub.Objective_Account__r.Account__r.VIP_Instance__c + ' / ' + sub.Objective_Account__r.Account__r.SalesOrg__c + ' / ' + sub.Objective_Account__r.Account__r.Warehouse__c, 'label' => sub.Objective_Account__r.Account__r.VIP_Instance__c + ' / ' + sub.Objective_Account__r.Account__r.SalesOrg__c + ' / ' + sub.Objective_Account__r.Account__r.Warehouse__c});
                    currLocation = sub.Objective_Account__r.Account__r.VIP_Instance__c + ' / ' + sub.Objective_Account__r.Account__r.SalesOrg__c + ' / ' + sub.Objective_Account__r.Account__r.Warehouse__c;
                }                                                                
	        }
        }
        if (items.size() <= 0) {
            items.add(new Map<String, String>{'value' => 'None Found', 'label' => 'None Found'});
        }
    	return items;
	}

    @AuraEnabled
	public static List<Map<String, String>> getSalesReps(String ids) {        
    	List<Map<String, String>> items = new List<Map<String, String>>();        
        if (ids != '') {            
        	List<Id> objIds = ids.split(';');
			String currManager = '';
    		for (Objective_Submission__c sub : [SELECT Id, Objective_Account__r.Account__r.Owner.Id, Objective_Account__r.Account__r.Owner.Name, Objective_Account__r.Account__r.Owner.Manager.Name
                                                FROM Objective_Submission__c WHERE Objective_Account__r.Objective__r.Id IN :objIds AND Status__c = 'Approved' ORDER BY Objective_Account__r.Account__r.Owner.Manager.Name, Objective_Account__r.Account__r.Owner.Name ASC]) {                
				if (sub.Objective_Account__r.Account__r.Owner.Manager.Name != null && sub.Objective_Account__r.Account__r.Owner.Manager.Name != currManager) {
					items.add(new Map<String, String>{'value' => 'supv:' + sub.Objective_Account__r.Account__r.Owner.Manager.Id, 'label' => sub.Objective_Account__r.Account__r.Owner.Manager.Name});                                                           
                    currManager = sub.Objective_Account__r.Account__r.Owner.Manager.Name;
                }                                                    
                if (sub.Objective_Account__r.Account__r.Owner != null && !items.contains(new Map<String, String>{'value' => sub.Objective_Account__r.Account__r.Owner.Id, 'label' => ' - ' + sub.Objective_Account__r.Account__r.Owner.Name})) {               		
                    items.add(new Map<String, String>{'value' => sub.Objective_Account__r.Account__r.Owner.Id, 'label' => ' - ' + sub.Objective_Account__r.Account__r.Owner.Name});    
                }	            
	        }
        }
        if (items.size() <= 0) {
            items.add(new Map<String, String>{'value' => 'None Found', 'label' => 'None Found'});
        }
    	return items;
	}   
    
}