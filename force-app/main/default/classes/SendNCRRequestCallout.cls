public without sharing class SendNCRRequestCallout {

	@InvocableMethod(label='Send NCR Request' description='Calls the API to send the NCR Request to the DMO Team')
    public static void sendNCRRequest(List<Id> ncrIds){
    	//Query the Prospective Customer for all the values we need to send in the callout
     	Lead ncrRequest =  LeadDAO.getLeadById(ncrIds[0]);
        //To Store JSON
        JSONGenerator ncrJSON = JSON.createGenerator(true);
        //First try to save the request to make sure there are no validation errors
        try {          			
        	ncrJSON.writeStartObject();
        	ncrJSON.writeFieldName('newCustomerRequest');
        	ncrJSON.writeStartObject();
        	ncrJSON.writeStringField('businessUnit', ncrRequest.Business_Unit__c);
        	 //Changes as per 2337
             if(string.valueOf(ncrRequest.OwnerId).startsWith('00G')){
                    if(ncrRequest.Requested_For__c != null){
                        ncrJSON.writeStringField('employeeNumber', getEmployeeId(ncrRequest.Requested_For__c));
                    }
                }else{
                    String profileName = getUserProfileName(ncrRequest.OwnerId);
                    String callCenterProfiles =System.label.CallCenterProfileNames;
                    List<String> callCenterProfileList = callCenterProfiles.split(',');
                    if(callCenterProfileList.contains(profileName) && ncrRequest.Requested_For__c != null){
                         ncrJSON.writeStringField('employeeNumber', getEmployeeId(ncrRequest.Requested_For__c));
                    }else{
                         ncrJSON.writeStringField('employeeNumber', getEmployeeId(ncrRequest.OwnerId));    
                     }
                }

      
        	ncrJSON.writeFieldName('newCustomer');
        	ncrJSON.writeStartObject();

        	if (ncrRequest.Company.length() > 25) {
				ncrJSON.writeStringField('dbaName', replaceSmartQuotes(ncrRequest.Company.substring(0, 24)).toUpperCase());      //Take only the first 25 characters
	        } else {
	            ncrJSON.writeStringField('dbaName', replaceSmartQuotes(ncrRequest.Company).toUpperCase());
	        }
	        ncrJSON.writeStringField('licenseeName', replaceSmartQuotes(ncrRequest.Licensee_Name__c).toUpperCase());
	        if (ncrRequest.Street.length() > 25) {
	        	ncrJSON.writeStringField('streetAddress', replaceSmartQuotes(replaceLineBreaks(ncrRequest.Street.substring(0,24))).toUpperCase());  //Take only the first 25 characters
	        } else {
	            ncrJSON.writeStringField('streetAddress', replaceSmartQuotes(replaceLineBreaks(ncrRequest.Street)).toUpperCase());
	        }
	        if (ncrRequest.City.length() > 15) {
	        	ncrJSON.writeStringField('cityName', replaceSmartQuotes(ncrRequest.City.substring(0,14)).toUpperCase());      //Take only the first 15 characters
	        } else {
	            ncrJSON.writeStringField('cityName', replaceSmartQuotes(ncrRequest.City).toUpperCase());
	        }
	        ncrJSON.writeStringField('state', ncrRequest.State.toUpperCase());
	        String zip = ncrRequest.PostalCode.replaceAll('[^0-9]','');
    	    if (zip.length() > 5) {
	        	ncrJSON.writeStringField('zipCode5', zip.substring(0,4));       //Take only the first 5 digits
	        } else {
	            ncrJSON.writeStringField('zipCode5', zip);
	        }
	        ncrJSON.writeStringField('county', ncrRequest.County__c);
	        String buyerName = replaceSmartQuotes(ncrRequest.FirstName + ' ' + ncrRequest.LastName);
	        if (buyerName.length() > 30) {
	        	ncrJSON.writeStringField('buyerName',buyerName.substring(0,29).toUpperCase());      //Take only the first 30 characters
	        } else {
	            ncrJSON.writeStringField('buyerName',buyerName.toUpperCase());
	        }
			ncrJSON.writeStringField('phoneNumber', ncrRequest.Phone.replaceAll('[^0-9]',''));   	//Need to strip out all formatting
	        if (ncrRequest.Fax != null) {
				ncrJSON.writeStringField('fax', ncrRequest.Fax.replaceAll('[^0-9]',''));            //Need to strip out all the formatting
	        } else {
	            ncrJSON.writeStringField('fax', '');
	        }
			ncrJSON.writeStringField('license1Number', ncrRequest.License_1__c.toUpperCase());
			ncrJSON.writeStringField('license1ExpDate', formatDate(ncrRequest.License_Expiration_Date__c));
			ncrJSON.writeStringField('licenseType', convertToCode('License Type', ncrRequest.License_Type__c));
			ncrJSON.writeStringField('taxJurisdiction', convertToCode('taxJurisdiction', ncrRequest.taxJurisdiction__c));
			ncrJSON.writeStringField('licensedAccountStatus', convertToCode('License Status', ncrRequest.License_Status__c));
			ncrJSON.writeStringField('taxID', convertString(ncrRequest.Tax_ID_Seller_Permit__c));
	       	ncrJSON.writeStringField('salesman1', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Beer_Salesman_1__c));
	        if (ncrRequest.Beer_Salesman_2__c != null) {
				ncrJSON.writeStringField('salesman2', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Beer_Salesman_2__c));
	        } else {
	            ncrJSON.writeStringField('salesman2', '');
	        }
	        if (ncrRequest.Beer_Salesman_3__c != null) {            
	        	ncrJSON.writeStringField('salesman4', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Beer_Salesman_3__c));
	        } else {
	            ncrJSON.writeStringField('salesman4', '');
	        }
	        if (ncrRequest.Supervisor__c != null) {
				ncrJSON.writeStringField('supervisor1', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Supervisor__c));
			} else {
	            ncrJSON.writeStringField('supervisor1', '');
	        }
	        if (ncrRequest.Supervisor_2__c != null) {
				ncrJSON.writeStringField('supervisor4', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Supervisor_2__c));
			} else {
				ncrJSON.writeStringField('supervisor4', '');
	        }
	        if (ncrRequest.Supervisor_3__c != null) {
				ncrJSON.writeStringField('wineSalesman1', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Supervisor_3__c));
			} else {
				ncrJSON.writeStringField('wineSalesman1', '');
	        }
            /*Changes for BSSP-2071 on hold due to DMO Team dependencies.  When this story is reactivated, just need to uncomment these lines
	        if (ncrRequest.Beer_Salesman_5__c != null) {
				ncrJSON.writeStringField('salesman5', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Beer_Salesman_5__c));
			} else {
				ncrJSON.writeStringField('salesman5', '');
	        }
	        if (ncrRequest.Beer_Salesman_6__c != null) {
				ncrJSON.writeStringField('salesman6', getRoute(ncrRequest.Sell_Type__c, ncrRequest.Beer_Salesman_6__c));
			} else {
				ncrJSON.writeStringField('salesman6', '');
	        }
			*/
            ncrJSON.writeStringField('packageType', convertToCode('Package Type', ncrRequest.Package_Type__c));
			ncrJSON.writeStringField('draftStatus', convertToCode('Draft Status', ncrRequest.Draft_Status__c));
			ncrJSON.writeStringField('seasonalCloseDate', convertMonth(ncrRequest.Seasonal_Close_Month__c));        
			ncrJSON.writeStringField('seasonalOpenDate', convertMonth(ncrRequest.Seasonal_Open_Month__c));
			ncrJSON.writeStringField('displayStatus', convertToCode('Displayable', ncrRequest.Displayable__c));
			ncrJSON.writeStringField('posAllowed', convertToCode('POS Materials', ncrRequest.POS_Materials__c));
			ncrJSON.writeStringField('specialInstructions', convertString(ncrRequest.Special_Instructions_Short__c));                
			ncrJSON.writeStringField('accountSubclass', convertToCode('Sub Class', ncrRequest.Subclass__c));
			ncrJSON.writeStringField('sellType', convertToCode('Sell Type', ncrRequest.Sell_Type__c));
	        if (ncrRequest.Chain__c != null) {
				ncrJSON.writeStringField('chainCode', ncrRequest.Chain__r.Chain_Id__c);
	        } else {
	            ncrJSON.writeStringField('chainCode', '');
	        }
			ncrJSON.writeStringField('chainStatus', convertToCode('Chain/Independent', ncrRequest.Chain_Independent__c));
			ncrJSON.writeStringField('digitChain3', '');   //Was decided this field is no longer needed so sending a blank value
			ncrJSON.writeStringField('beerIndustryVolume', convertToCode('Beer Industry Volume', ncrRequest.Beer_Industry_Volume__c));
			ncrJSON.writeStringField('civilianMilitaryFlag', convertToCode('Civilian/Military', ncrRequest.Civilian_Military__c));
			ncrJSON.writeStringField('ethnicPatron', convertToCode('Ethnic - Patron', ncrRequest.Ethnic_Patron__c));
			ncrJSON.writeStringField('lifestyle', convertToCode('Lifestyle', ncrRequest.Lifestyle__c));
			ncrJSON.writeStringField('occupationCode', convertToCode('Occupation Code', ncrRequest.Occupation_Code__c));
			ncrJSON.writeStringField('ageCode', convertToCode('Patron Age Code', ncrRequest.Patron_Age_Code__c));
			ncrJSON.writeStringField('residence', convertToCode('Residence', ncrRequest.Residence__c));
			ncrJSON.writeStringField('company', convertToCode('Company', ncrRequest.Company__c));
			ncrJSON.writeStringField('warehouse', convertToCode('Warehouse', ncrRequest.Warehouse__c));
			ncrJSON.writeStringField('printUpcBarcode', convertToCode('PDA Print UPC Barcode', convertString(ncrRequest.PDA_Print_UPC_Barcode__c)));
			ncrJSON.writeStringField('upcPrintCode', convertToCode('UPC Print', convertString(ncrRequest.UPC_Print__c)));        
	        ncrJSON.writeStringField('printBarcodedInvoice', convertToCode('Barcoded Invoice', convertString(ncrRequest.Barcoded_Invoice__c)));        
			ncrJSON.writeStringField('isPrintUcscodeLabels', convertBoolean(ncrRequest.Print_UCS_Code_Labels__c));
			ncrJSON.writeStringField('isSeparateEmptyInvoice', convertBoolean(ncrRequest.Print_Separate_Empty_Invoice__c));
			ncrJSON.writeStringField('termCode', convertToCode('Terms', ncrRequest.Terms__c));
			ncrJSON.writeStringField('premiseOnOff', convertToCode('Premise', ncrRequest.Premise__c));
			ncrJSON.writeStringField('accountClass', convertToCode('Class', ncrRequest.Class__c));
			ncrJSON.writeStringField('deliveryDays', convertDeliveryDays(ncrRequest.Requested_Delivery_Days__c));
			ncrJSON.writeStringField('storeLocationNumber', convertString(ncrRequest.Store_Number__c));
	        if (ncrRequest.Email.length() > 60) {
				ncrJSON.writeStringField('emailAddress', ncrRequest.Email.substring(0,59));   					//Take only the first 60 characters
	        } else {
	            ncrJSON.writeStringField('emailAddress', convertString(ncrRequest.Email));
	        }
			ncrJSON.writeStringField('customerInstructions', replaceSmartQuotes(convertString(ncrRequest.Special_Instructions_Long__c)));
			ncrJSON.writeStringField('timeWindow1Start', convertString(ncrRequest.Delivery_Open_Time_1__c));
			ncrJSON.writeStringField('timeWindow1End', convertString(ncrRequest.Delivery_Close_Time_1__c));        
			ncrJSON.writeStringField('timeWindow2Start', convertString(ncrRequest.Delivery_Open_Time_2__c));
			ncrJSON.writeStringField('timeWindow2End', convertString(ncrRequest.Delivery_Close_Time_2__c));
			ncrJSON.writeStringField('mdmComment', replaceSmartQuotes(replaceLineBreaks(convertString(ncrRequest.Comments_for_MDM_Team__c))));
	        ncrJSON.writeEndObject();
	        ncrJSON.writeEndObject();
	        ncrJSON.writeEndObject();
	        String jsonString = ncrJSON.getAsString();
	        
	        //Send the Request
	        HttpResponse ncrResponse = MulesoftUtility.mulesoftCallout('New Customer Request', null, null, null, jsonString);
	        //Update the JSON we sent on the Request for Troubleshooting
	        if (ncrResponse.getStatusCode() == 201) {
	            //Request was sent successfully
	            ncrRequest.Status = 'Submitted to DMO';
	            //Note:  We decided not to send an email here because the user already gets one when the request is approved
	            //Parse JSON response to get the NCR GUID
	        	JSONParser parser = JSON.createParser(ncrResponse.getBody());
	        	while (parser.nextToken() != null) {
	            	if ((parser.getText() == 'ncrGuid')) {
		                parser.nextToken();                
		                ncrRequest.NCRGUID__c = parser.getText();
			        }
		        }           
	        } else {
	            //Request was not sent successfully
	            ncrRequest.Status = 'Error Posting to DMO';
	            if (ncrRequest.Callout_Retry_Attempts__c < 2) {	//2 retries before posting the error
	            	ncrRequest.Callout_Retry_Attempts__c += 1;
	            } else {
	            	processNCRFailure(ncrRequest, 'NCR API Posting Error', ncrRequest.ResponseJSON__c);
	            }
	        }
			ncrRequest.Allow_Status_Update__c = true;
	        ncrRequest.RequestJSON__c = jsonString;
	        ncrRequest.ResponseJSON__c = ncrResponse.toString() + ' : ' + ncrResponse.getBody();        
		    update ncrRequest;            
        } catch (Exception e) {
			processNCRFailure(ncrRequest, 'NCR Error', e.getMessage());
        }            
    }
    
    private static String formatDate(Date fmtDate) {        
        return String.valueOf(fmtDate).replaceAll('-','');
    }

    private static String getEmployeeId(Id empId) {
		User emp = [SELECT FederationIdentifier FROM User WHERE Id = :empId LIMIT 1];        
        if (emp != null) {
            if (emp.FederationIdentifier != null) {
        		return emp.FederationIdentifier;
            } else {
                return '';
            }
        } else {
            return '';
        }
    }

    private static String getUserProfileName(Id empId) {
		User emp = [SELECT profile.name FROM User WHERE Id = :empId LIMIT 1];        
        if (emp != null) {
        		return emp.profile.name;
         }else {
            return '';
        }
    }

    
    private static String getRoute(String sellType, Id empId) {
		User emp = [SELECT Assigned_route__c, LastName FROM User WHERE Id = :empId LIMIT 1];        
       	if (emp.LastName.contains('Inside')) {
            if (sellType == 'Inside Sales') {
        		return '300';
            } else if (sellType == 'National Accounts') {
                return '500';
			} else {
                return '';
            }
        } else if (emp.LastName == 'Open') {
            return '-4';
        } else if (emp != null) {
            if (emp.Assigned_route__c != null) {
        		return emp.Assigned_route__c;
            } else {                
                return '';
            }
        } else {
            return '';
        }
    }
    
    private static String convertToCode(String configType, String val) {
        try {    
        	NCR_Config_Data__mdt config = [SELECT Field_Value_To__c FROM NCR_Config_Data__mdt WHERE MasterLabel = :configType AND Field_Value_On_UI__c = :val LIMIT 1];
        	if (config != null) {
	        	return config.Field_Value_To__c;
	        } else {
	            return '';
	        }
        } catch (Exception e) {
            return '';
        }
    }
    
    private static String convertBoolean(Boolean val) {
        if (val == null) {
            return '';
        } else if (val) {
            return 'Y';
        } else {
        	return 'N';
        }
    }

    private static String convertDeliveryDays(String val) {        
        return val.replaceAll('Monday','M').replaceAll('Tuesday','TU').replaceAll('Wednesday','W').replaceAll('Thursday','TH').replaceAll('Friday','F').replaceAll(';',',');
    }
    
    private Static String convertString(String val) {
        if (val == null) {
            val = '';
        }
        return val;
    }
    
    private Static String replaceLineBreaks(String val) {
		val = val.replace('\r\n', ' ');
		val = val.replace('\n', ' ');
		val = val.replace('\r', ' ');
        return val;
    }

    private Static String replaceSmartQuotes(String val) {
		val = val.replace('‘', '\'');
		val = val.replace('’', '\'');
		val = val.replace('“', '"');
        val = val.replace('”', '"');
        return val;
    }
    
    @TestVisible
    private Static String convertMonth(String val) {
        String convertVal = '';
        if (val == 'January') {
            convertVal = '01';
        } else if (val == 'February') {
            convertVal = '02';
        } else if (val == 'March') {
            convertVal = '03';
        } else if (val == 'April') {
        	convertVal = '04';
        } else if (val == 'May') {
        	convertVal = '05';
        } else if (val == 'June') {
        	convertVal = '06';
        } else if (val == 'July') {
        	convertVal = '07';
        } else if (val == 'August') {
        	convertVal = '08';
        } else if (val == 'September') {
        	convertVal = '09';
        } else if (val == 'October') {
        	convertVal = '10';
        } else if (val == 'November') {
        	convertVal = '11';
        } else if (val == 'December') {
        	convertVal = '12';
		}
        return convertVal;
    }
        
   public static void processNCRFailure(Lead ncr, String errorSubject, String errorBody) {
		//Get the E360 Support Email Address
		Reyes_Org_Setting__c org = Reyes_Org_Setting__c.getInstance();
        String toAddress = org.E360_Support_Email__c;
        if (isEmailTurnedOn()) {   //Check if Email Deliverability is on (for testing in lower environments)
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(errorSubject);
           	email.setHtmlBody('There was an error sending NCR request for ' + ncr.Company + ' to the DMO.<br><br>' + errorBody + '<br><a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + ncr.Id + '">Link</a>');
            if (toAddress != null) {
            	email.setToAddresses(new List<String>{toAddress});
                List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
            }    	    
        }
    }
    
    public static Boolean isEmailTurnedOn() {
        try {
            Messaging.reserveSingleEmailCapacity(0);
            return true;
        } catch (System.NoAccessException e) {
            return false;        
        }
    }
                                 
}