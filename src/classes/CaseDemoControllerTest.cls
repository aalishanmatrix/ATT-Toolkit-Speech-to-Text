@isTest
public class CaseDemoControllerTest{
	
    public static testmethod void testCordovaJS() {
        Test.setCurrentPage(Page.CaseDemo);
        CaseDemoController contr = new CaseDemoController();
        
        //Simulate that the page is being invoked from an iPhone
        ApexPages.currentPage().getHeaders().put('User-Agent', 'iPhone');
        
        //Invoke the dynamic PhoneGapJS VF component
        Component.Apex.IncludeScript phoneGapJS = contr.getCordovaJS();
        System.assertEquals(phoneGapJS.expressions.value,'{!URLFOR($Resource.Cordova_2_3_0_iOS)}','iOS version of PhoneGap JS was not included');
        
        ApexPages.currentPage().getHeaders().put('User-Agent', 'Android');
        
        //Invoke the dynamic PhoneGapJS VF component
        phoneGapJS = contr.getCordovaJS();
        System.assertEquals(phoneGapJS.expressions.value,'{!URLFOR($Resource.Cordova_2_3_0_Android)}','Android version of PhoneGap JS was not included');
    }
    
    public static testmethod void testAllCasesQuery(){
        TestUtils.createMockCallouts();
        TestUtils.createTestData();
        Test.setCurrentPage(Page.CaseDemo);
        
        User testUser = [select Id from User where UserName='test@atttest.com' limit 1];
        System.runAs(testUser) {
        	List<Case> cases = CaseDemoController.getCaseRecs();
        	System.assertEquals(cases.size(), 1, 'Case record not found');
        }
    }
    
    public static testmethod void testSearchCases(){
        TestUtils.createMockCallouts();
        Test.setCurrentPage(Page.CaseDemo);
        CaseDemoController.SearchResult result = CaseDemoController.searchCases('Test', 'audio/wav');
        System.assertEquals(result.cases.size(), 0, 'Speech to text test failed');
    }

}