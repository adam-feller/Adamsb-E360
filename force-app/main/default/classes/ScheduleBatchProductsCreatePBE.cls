public class ScheduleBatchProductsCreatePBE implements Schedulable {

    public void execute(SchedulableContext sc) {
        BatchProductsCreatePricebookEntries batchProductsPBECreate = new BatchProductsCreatePricebookEntries();        
        batchProductsPBECreate.query = 'SELECT Id FROM Product2  WHERE (createddate = TODAY OR createddate = YESTERDAY) AND Id NOT IN (SELECT Product2Id FROM PricebookEntry )';
        Database.executebatch(batchProductsPBECreate, 10);
    }
}