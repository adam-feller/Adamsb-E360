@isTest
public with sharing class PriorityProductsWrapperTest {
    
	static testMethod void testParse() {
        Test.startTest();
        // String priorityListResponseBody = priorityListResponse.getBody(); 
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [{ "priorityType": "Controllable Core Product", "productExternalId": 11455, "productContainerType": "Bottle", "productInvoiceDate": "2022-12-23T06:00:00",  "productWarehouseAvailableQty": 8919,  "productOnHandQty": 0.0000,      "suggestionSource": 1,      "suggestionStory": null,      "suggestionScore": 0,      "suggestionDatetime": "2022-09-30T12:36:41.047"    }	  ]}';
        
        PriorityProductsWrapper priorityProdWrapperObj = (PriorityProductsWrapper)JSON.deserialize(priorityListResponseBody, PriorityProductsWrapper.class);
       // System.debug('priorityProdWrapperObj   *** '+ priorityProdWrapperObj);
        
        
        List<PriorityProductsWrapper.priorityProducts> priorityListDetailsList = priorityProdWrapperObj.priorityProducts;
     
		String json = '{ \"customerExternalId\": \"FDI*40891\", \"priorityProducts\": [{ \"priorityType\": \"Controllable Core Product\", \"productExternalId\": 11455, \"productContainerType\": \"Bottle\", \"productInvoiceDate\": \"2022-12-23T06:00:00\",  \"productWarehouseAvailableQty\": 8919,  \"productOnHandQty\": 0.0000,      \"suggestionSource\": 1,      \"suggestionStory\": null,      \"suggestionScore\": 0,      \"suggestionDatetime\": \"2022-09-30T12:36:41.047\"    }	  ]}\'';
		PriorityProductsWrapper obj = PriorityProductsWrapper.parse(json);
		System.assert(obj != null);
        
        PriorityProductsWrapper wrapperObj = new PriorityProductsWrapper();
        wrapperObj.customerExternalId ='123';
        wrapperObj.PriorityProducts =priorityProdWrapperObj.priorityProducts;

        Test.stopTest();
        
        
    }
}