@isTest
public class TestUtils{
    
    public static String acctAddress = '1 Market Street, San Francisco, CA';
    
    public static void createMockCallouts(){
        String googleMapURL = 	'http://maps.googleapis.com/maps/api/staticmap'+
                                '?size=300x300&sensor=false&markers=size:mid%7Ccolor:red%7C'+
                                EncodingUtil.urlEncode(TestUtils.acctAddress, 'UTF-8');
        
        TestHttpMockFactory.SingleRequestMock googleMapMock = new TestHttpMockFactory.SingleRequestMock(200, 
                                                                                          'Complete', 
                                                                                          Blob.valueOf('Test'),
                                                                                          new Map<String, String>());

        TestHttpMockFactory.SingleRequestMock attMMSOutboundMock = TestHttpMockFactory.getSuccessfulCreatedHttpMock(
		'{"Id": "MMSa9b17cdae1f70f8c",' +
    		'"ResourceReference": {' +
        		'"ResourceUrl": "https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b17cdae1f70f8c"' +
    		'}' +
    	'}');

        TestHttpMockFactory.SingleRequestMock attSpeech2TextMock = new TestHttpMockFactory.SingleRequestMock(200,'Complete',
		'{"Recognition":{"ResponseId":"3e78bd2eb204ad7f574e95a7c6a52625","NBest":[{"WordScores":[1,1],"Confidence":1,"Grade":"accept","ResultText":"Test","Words":["Test"],"LanguageId":"en-us","Hypothesis":"Test"}]}}');

        TestHttpMockFactory.SingleRequestMock attOAuthMock = new TestHttpMockFactory.SingleRequestMock(200,'Complete',
		'{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"0","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}');
        
        HttpCalloutMock multimock = 
            new TestHttpMockFactory.MultiRequestMock(new Map<String,HttpCalloutMock>{
				googleMapURL => googleMapMock,
				ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.SEND_MMS) => attMMSOutboundMock,
                ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.SPEECH) => attSpeech2TextMock,
                ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.GET_ACCESS_TOKEN) => attOAuthMock});
		
		
		Test.setMock(HttpCalloutMock.class, multimock);
    }
    
    public static void createTestData(){
        /* Get a profile for the specified licensetype. */
        Profile p = [SELECT Id FROM Profile WHERE UserLicense.name = 'Salesforce' LIMIT 1]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test@atttest.com', MobilePhone='4154154154');
        
        insert u;
        Account a = new Account (name = 'Test', 
                                 BillingStreet = acctAddress);
        insert a;
        Case c = new Case(Status = 'New',
                          AccountId = a.Id,
                          OwnerId=u.Id);
		insert c;
    }

}