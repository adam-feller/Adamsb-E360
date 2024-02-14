public class GreenmileRouteInfo {

	public class Organization {
		public Integer id {get;set;} 
		public String creationDate {get;set;} 
		public String lastModificationDate {get;set;} 
		public String key {get;set;} 
		public ParentOrganization parentOrganization {get;set;} 
		public String description {get;set;} 
		public PreferedLocale preferedLocale {get;set;} 
		public TimeZone timeZone {get;set;} 
		//public Object listenerOrganizations {get;set;} 
		public String unitSystem {get;set;} 

		public Organization(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'creationDate') {
							creationDate = parser.getText();
						} else if (text == 'lastModificationDate') {
							lastModificationDate = parser.getText();
						} else if (text == 'key') {
							key = parser.getText();
						} else if (text == 'parentOrganization') {
							parentOrganization = new ParentOrganization(parser);
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'preferedLocale') {
							preferedLocale = new PreferedLocale(parser);
						} else if (text == 'timeZone') {
							timeZone = new TimeZone(parser);
						} else if (text == 'listenerOrganizations') {
							//listenerOrganizations = parser.readValueAs(Object.class);
						} else if (text == 'unitSystem') {
							unitSystem = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Organization consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ParentOrganization {
		public Integer id {get;set;} 
		public String creationDate {get;set;} 
		public String lastModificationDate {get;set;} 
		public String key {get;set;} 
		public ParentOrganization parentOrganization {get;set;} 
		public String description {get;set;} 
		public PreferedLocale preferedLocale {get;set;} 
		public TimeZone timeZone {get;set;} 
		//public Object listenerOrganizations {get;set;} 
		public String unitSystem {get;set;} 
	
		public ParentOrganization(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'creationDate') {
							creationDate = parser.getText();
						} else if (text == 'lastModificationDate') {
							lastModificationDate = parser.getText();
						} else if (text == 'key') {
							key = parser.getText();
						} else if (text == 'parentOrganization') {
							parentOrganization = new ParentOrganization(parser);
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'preferedLocale') {
							preferedLocale = new PreferedLocale(parser);
						} else if (text == 'timeZone') {
							timeZone = new TimeZone(parser);
						} else if (text == 'listenerOrganizations') {
							//listenerOrganizations = parser.readValueAs(Object.class);
						} else if (text == 'unitSystem') {
							unitSystem = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ParentOrganization consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Driver {
		public Integer id {get;set;} 
		public String login {get;set;} 
		public String key {get;set;} 
		public String name {get;set;} 

		public Driver(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'login') {
							login = parser.getText();
						} else if (text == 'key') {
							key = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Driver consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class TimeZone {
		public Integer id {get;set;} 
		public String description {get;set;} 
		public Integer rawOffsetMinutes {get;set;} 
		public String alias {get;set;} 
		public String timezoneName {get;set;} 

		public TimeZone(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'rawOffsetMinutes') {
							rawOffsetMinutes = parser.getIntegerValue();
						} else if (text == 'alias') {
							alias = parser.getText();
						} else if (text == 'timezoneName') {
							timezoneName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'TimeZone consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DriverAssignments {
		public Integer id {get;set;} 
		public Driver driver {get;set;} 

		public DriverAssignments(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'driver') {
							driver = new Driver(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'DriverAssignments consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PreferedLocale {
		public Integer id {get;set;} 
		public String key {get;set;} 
		public String language {get;set;} 
		public String description {get;set;} 
		public String dateFormat {get;set;} 
		public String timeFormat {get;set;} 
		public String preferedCurrency {get;set;} 
		public String decimalSymbol {get;set;} 
		public String digitalGrouping {get;set;} 

		public PreferedLocale(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'key') {
							key = parser.getText();
						} else if (text == 'language') {
							language = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'dateFormat') {
							dateFormat = parser.getText();
						} else if (text == 'timeFormat') {
							timeFormat = parser.getText();
						} else if (text == 'currency') {
							preferedCurrency = parser.getText();
						} else if (text == 'decimalSymbol') {
							decimalSymbol = parser.getText();
						} else if (text == 'digitalGrouping') {
							digitalGrouping = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PreferedLocale consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Stops {
		public Integer id {get;set;} 
		public Location location {get;set;} 
		public String plannedArrival {get;set;} 
		public String actualArrival {get;set;} 
		public String plannedService {get;set;} 
		public String plannedDeparture {get;set;}
		public String projectedArrival {get;set;}
		public String projectedDeparture {get;set;}
		public CancelCode cancelCode {get;set;} 
		public Integer plannedServiceTime {get;set;} 
		public Boolean hasPicture {get;set;} 
		public Boolean hasSignature {get;set;} 
		public String deliveryStatus {get;set;}
		public Boolean returned {get;set;} 
		public Boolean redelivered {get;set;} 
		public Boolean canceled {get;set;} 
		public String actualService {get;set;} 
		public String actualDeparture {get;set;} 
		public Integer actualServiceTime {get;set;} 
		public Double plannedSize1 {get;set;}
		public Double plannedSize2 {get;set;}
		public Double plannedSize3 {get;set;}
		public Double actualSize1 {get;set;}
		public Double actualSize2 {get;set;}
		public Double actualSize3 {get;set;}
	
		public Stops(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'location') {
							location = new Location(parser);
						} else if (text == 'plannedArrival') {
							plannedArrival = parser.getText();
						} else if (text == 'plannedService') {
							plannedService = parser.getText();
						} else if (text == 'plannedDeparture') {
							plannedDeparture = parser.getText();
						} else if (text == 'projectedArrival') {
							projectedArrival = parser.getText();
						} else if (text == 'projectedDeparture') {
							projectedDeparture = parser.getText();
						} else if (text == 'cancelCode') {
							cancelCode = new CancelCode(parser);
						} else if (text == 'plannedServiceTime') {
							plannedServiceTime = parser.getIntegerValue();
						} else if (text == 'hasPicture') {
							hasPicture = parser.getBooleanValue();
						} else if (text == 'hasSignature') {
							hasSignature = parser.getBooleanValue();
						} else if (text == 'returned') {
							returned = parser.getBooleanValue();
						} else if (text == 'redelivered') {
							redelivered = parser.getBooleanValue();
						} else if (text == 'canceled') {
							canceled = parser.getBooleanValue();
						} else if (text == 'deliveryStatus') {
							deliveryStatus = parser.getText();
						} else if (text == 'actualService') {
							actualService = parser.getText();
						} else if (text == 'actualDeparture') {
							actualDeparture = parser.getText();
						} else if (text == 'actualServiceTime') {
							actualServiceTime = parser.getIntegerValue();
						} else if (text == 'actualArrival') {
							actualArrival = parser.getText();
						} else if (text == 'plannedSize1') {
							plannedSize1 = parser.getDoubleValue();
						} else if (text == 'plannedSize2') {
							plannedSize2 = parser.getDoubleValue();
						} else if (text == 'plannedSize3') {
							plannedSize3 = parser.getDoubleValue();
						} else if (text == 'actualSize1') {
							actualSize1 = parser.getDoubleValue();
						} else if (text == 'actualSize2') {
							actualSize2 = parser.getDoubleValue();
						} else if (text == 'actualSize3') {
							actualSize3 = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Stops consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CancelCode {
		public Integer id {get;set;} 
		public String creationDate {get;set;} 
		public String lastModificationDate {get;set;} 
		public Organization organization {get;set;} 
		public String key {get;set;} 
		//public Object udfs {get;set;} 
		public String description {get;set;} 
		public Boolean enabled {get;set;} 

		public CancelCode(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'creationDate') {
							creationDate = parser.getText();
						} else if (text == 'lastModificationDate') {
							lastModificationDate = parser.getText();
						} else if (text == 'organization') {
							organization = new Organization(parser);
						} else if (text == 'key') {
							key = parser.getText();
						} else if (text == 'udfs') {
							//udfs = parser.readValueAs(Object.class);
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'enabled') {
							enabled = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'CancelCode consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Integer id {get;set;} 
	public Organization organization {get;set;}
 	public String routeDate {get;set;} 
	public List<Stops> stops {get;set;} 
	public String driversName {get;set;} 
	public List<DriverAssignments> driverAssignments {get;set;} 
	public String status {get;set;} 
	public Boolean hasPicture {get;set;} 
	public String errorMessage {get; set;}
	public String errorCode {get; set;}
	public String key {get; set;}
	public String description {get; set;}
	
	public GreenmileRouteInfo(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'id') {
						id = parser.getIntegerValue();
					} else if (text == 'date') {
						routeDate = parser.getText();
					} else if (text == 'key') {
						key = parser.getText();
					}else if (text == 'description') {
						description = parser.getText();
					}else if (text == 'organization') {
						organization = new Organization(parser);
					} else if (text == 'stops') {
						stops = arrayOfStops(parser);
					} else if (text == 'driversName') {
						driversName = parser.getText();
					} else if (text == 'driverAssignments') {
						driverAssignments = arrayOfDriverAssignments(parser);
					} else if (text == 'status') {
						status = parser.getText();
					} else if (text == 'hasPicture') {
						hasPicture = parser.getBooleanValue();
					} else {
						System.debug(LoggingLevel.WARN, 'GreenmileRouteInfo consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Location {
		public Integer id {get;set;} 
		public String key {get;set;} 
		public String description {get;set;} 
		public String addressLine1 {get;set;} 
		public String addressLine2 {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zipCode {get;set;}
		public String alternativeKey {get;set;} 

		public Location(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'key') {
							key = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'addressLine1') {
							addressLine1 = parser.getText();
						} else if (text == 'addressLine2') {
							addressLine2 = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'zipCode') {
							zipCode = parser.getText();
						} else if (text == 'alternativeKey') {
							alternativeKey = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Location consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static List<GreenmileRouteInfo> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfGreenmileRouteInfo(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    private static List<Stops> arrayOfStops(System.JSONParser p) {
        List<Stops> res = new List<Stops>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Stops(p));
        }
        return res;
    }

    private static List<GreenmileRouteInfo> arrayOfGreenmileRouteInfo(System.JSONParser p) {
        List<GreenmileRouteInfo> res = new List<GreenmileRouteInfo>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new GreenmileRouteInfo(p));
        }
        return res;
    }

    private static List<DriverAssignments> arrayOfDriverAssignments(System.JSONParser p) {
        List<DriverAssignments> res = new List<DriverAssignments>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DriverAssignments(p));
        }
        return res;
    }


}