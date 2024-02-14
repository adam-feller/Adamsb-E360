// Extension to delete all of the selected objects
public with sharing class MassDeleteOrdersExtension {

    ApexPages.StandardSetController setCon;
//    public String error { get; set; }
    public PageReference originalUrl { get; set; }

    public MassDeleteOrdersExtension(ApexPages.StandardSetController controller) {
        setCon = controller;
    }

    public String getMySelectedSize() {
        return setCon.getSelected().size() + '';
    }
    
    public PageReference deleteRecords(){
        
        originalUrl = setCon.cancel();
        List<SObject> delOrdersLst= new List<SObject>();
 //       delete setCon.getSelected();
         for (SObject sobj : setCon.getSelected()) {
         
         List<Order> orddata = [select id, status from Order where id = :(String)sobj.get('Id')];
                if (orddata[0].Status  != 'Posted to VIP') {
//                if (orddata[0].Status  != 'Pending') {
                       delOrdersLst.add(sobj); 
                } 
            }
            
            delete delOrdersLst;
 
        return originalUrl;
   
               
        
    }

}